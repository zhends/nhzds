#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class Changeset < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user
  has_many :file_changes, class_name: 'Change', dependent: :delete_all
  has_and_belongs_to_many :work_packages

  acts_as_journalized

  acts_as_event title: Proc.new { |o| "#{l(:label_revision)} #{o.format_identifier}" + (o.short_comments.blank? ? '' : (': ' + o.short_comments)) },
                description: :long_comments,
                datetime: :committed_on,
                url: Proc.new { |o| { controller: '/repositories', action: 'revision', id: o.repository.project, rev: o.identifier } },
                author: Proc.new { |o| o.author }

  acts_as_searchable columns: 'comments',
                     include: { repository: :project },
                     references: [:repositories],
                     project_key: "#{Repository.table_name}.project_id",
                     date_column: 'committed_on'

  validates_presence_of :repository_id, :revision, :committed_on, :commit_date
  validates_uniqueness_of :revision, scope: :repository_id
  validates_uniqueness_of :scmid, scope: :repository_id, allow_nil: true

  scope :visible, -> (*args) {
    includes(repository: :project)
      .references(:projects)
      .merge(Project.allowed_to(args.first || User.current, :view_changesets))
  }

  def revision=(r)
    write_attribute :revision, (r.nil? ? nil : r.to_s)
  end

  # Returns the identifier of this changeset; depending on repository backends
  def identifier
    if repository.class.respond_to? :changeset_identifier
      repository.class.changeset_identifier self
    else
      revision.to_s
    end
  end

  def committed_on=(date)
    self.commit_date = date.to_date
    super
  end

  # Returns the readable identifier
  def format_identifier
    if repository.class.respond_to? :format_changeset_identifier
      repository.class.format_changeset_identifier self
    else
      identifier
    end
  end

  def project
    repository.project
  end

  def author
    user || committer.to_s.split('<').first
  end

  # Delegate to a Repository's log encoding
  def repository_encoding
    if repository.present?
      repository.repo_log_encoding
    end
  end

  # Committer of the Changeset
  #
  # Attribute reader for committer that encodes the committer string to
  # the repository log encoding (e.g. UTF-8)
  def committer
    self.class.to_utf8(read_attribute(:committer), repository.repo_log_encoding)
  end

  before_create :sanitize_attributes
  before_create :assign_openproject_user_from_comitter
  after_create :scan_comment_for_work_package_ids

  TIMELOG_RE = /
    (
    ((\d+)(h|hours?))((\d+)(m|min)?)?
    |
    ((\d+)(h|hours?|m|min))
    |
    (\d+):(\d+)
    |
    (\d+([\.,]\d+)?)h?
    )
    /x

  def scan_comment_for_work_package_ids
    return if comments.blank?
    # keywords used to reference work packages
    ref_keywords = Setting.commit_ref_keywords.downcase.split(',').map(&:strip)
    ref_keywords_any = ref_keywords.delete('*')
    # keywords used to fix work packages
    fix_keywords = Setting.commit_fix_keywords.downcase.split(',').map(&:strip)

    kw_regexp = (ref_keywords + fix_keywords).map { |kw| Regexp.escape(kw) }.join('|')

    referenced_work_packages = []

    comments.scan(/([\s\(\[,-]|^)((#{kw_regexp})[\s:]+)?(#\d+(\s+@#{TIMELOG_RE})?([\s,;&]+#\d+(\s+@#{TIMELOG_RE})?)*)(?=[[:punct:]]|\s|<|$)/i) do |match|
      action = match[2]
      refs = match[3]
      next unless action.present? || ref_keywords_any

      refs.scan(/#(\d+)(\s+@#{TIMELOG_RE})?/).each do |m|
        work_package = find_referenced_work_package_by_id(m[0].to_i)
        hours = m[2]
        if work_package
          referenced_work_packages << work_package
          fix_work_package(work_package) if fix_keywords.include?(action.to_s.downcase)
          log_time(work_package, hours) if hours && Setting.commit_logtime_enabled?
        end
      end
    end

    referenced_work_packages.uniq!
    self.work_packages = referenced_work_packages unless referenced_work_packages.empty?
  end

  def short_comments
    @short_comments || split_comments.first
  end

  def long_comments
    @long_comments || split_comments.last
  end

  def text_tag
    if scmid?
      "commit:#{scmid}"
    else
      "r#{revision}"
    end
  end

  # Returns the previous changeset
  def previous
    @previous ||= Changeset.where(['id < ? AND repository_id = ?', id, repository_id]).order('id DESC').first
  end

  # Returns the next changeset
  def next
    @next ||= Changeset.where(['id > ? AND repository_id = ?', id, repository_id]).order('id ASC').first
  end

  # Creates a new Change from it's common parameters
  def create_change(change)
    Change.create(changeset: self,
                  action: change[:action],
                  path: change[:path],
                  from_path: change[:from_path],
                  from_revision: change[:from_revision])
  end

  private

  # Finds a work_package that can be referenced by the commit message
  # i.e. a work_package that belong to the repository project, a subproject or a parent project
  def find_referenced_work_package_by_id(id)
    return nil if id.blank?
    work_package = WorkPackage.includes(:project).find_by(id: id.to_i)
    if work_package
      unless work_package.project && (project == work_package.project || project.is_ancestor_of?(work_package.project) || project.is_descendant_of?(work_package.project))
        work_package = nil
      end
    end
    work_package
  end

  def fix_work_package(work_package)
    status = Status.find_by(id: Setting.commit_fix_status_id.to_i)
    if status.nil?
      logger.warn("No status matches commit_fix_status_id setting (#{Setting.commit_fix_status_id})") if logger
      return work_package
    end

    # the work_package may have been updated by the closure of another one (eg. duplicate)
    work_package.reload
    # don't change the status if the work package is closed
    return if work_package.status && work_package.status.is_closed?

    work_package.add_journal(user || User.anonymous, ll(Setting.default_language, :text_status_changed_by_changeset, text_tag))
    work_package.status = status
    unless Setting.commit_fix_done_ratio.blank?
      work_package.done_ratio = Setting.commit_fix_done_ratio.to_i
    end
    Redmine::Hook.call_hook(:model_changeset_scan_commit_for_issue_ids_pre_issue_update,
                            changeset: self, issue: work_package)
    unless work_package.save(validate: false)
      logger.warn("Work package ##{work_package.id} could not be saved by changeset #{id}: #{work_package.errors.full_messages}") if logger
    end
    work_package
  end

  def log_time(work_package, hours)
    time_entry = TimeEntry.new(
      user: user,
      hours: hours,
      work_package: work_package,
      spent_on: commit_date,
      comments: l(:text_time_logged_by_changeset, value: text_tag, locale: Setting.default_language)
    )
    time_entry.activity = log_time_activity unless log_time_activity.nil?

    unless time_entry.save
      logger.warn("TimeEntry could not be created by changeset #{id}: #{time_entry.errors.full_messages}") if logger
    end
    time_entry
  end

  def log_time_activity
    if Setting.commit_logtime_activity_id.to_i > 0
      TimeEntryActivity.find_by(id: Setting.commit_logtime_activity_id.to_i)
    end
  end

  def split_comments
    comments =~ /\A(.+?)\r?\n(.*)\z/m
    @short_comments = $1 || comments
    @long_comments = $2.to_s.strip
    [@short_comments, @long_comments]
  end

  public

  # Strips and reencodes a commit log before insertion into the database
  def self.normalize_comments(str, encoding)
    Changeset.to_utf8(str.to_s.strip, encoding)
  end

  private

  def sanitize_attributes
    self.committer = self.class.to_utf8(committer, repository.repo_log_encoding)
    self.comments  = self.class.normalize_comments(comments, repository.repo_log_encoding)
  end

  def assign_openproject_user_from_comitter
    self.user = repository.find_committer_user(committer)
    add_journal(user || User.anonymous, comments)
  end

  # TODO: refactor to a standard helper method
  def self.to_utf8(str, encoding)
    return str if str.nil?
    str.force_encoding('ASCII-8BIT') if str.respond_to?(:force_encoding)
    if str.empty?
      str.force_encoding('UTF-8') if str.respond_to?(:force_encoding)
      return str
    end
    normalized_encoding = encoding.blank? ? 'UTF-8' : encoding
    if str.respond_to?(:force_encoding)
      if normalized_encoding.upcase != 'UTF-8'
        str.force_encoding(normalized_encoding)
        str = str.encode('UTF-8', invalid: :replace,
                                  undef: :replace, replace: '?')
      else
        str.force_encoding('UTF-8')
        unless str.valid_encoding?
          str = str.encode('US-ASCII', invalid: :replace,
                                       undef: :replace, replace: '?').encode('UTF-8')
        end
      end
    else

      txtar = ''
      begin
        txtar += str.encode('UTF-8', normalized_encoding)
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
        txtar += $!.success
        str = '?' + $!.failed[1, $!.failed.length]
        retry
      rescue
        txtar += $!.success
      end
      str = txtar
    end
    str
  end
end
