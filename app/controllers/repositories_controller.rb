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

require 'SVG/Graph/Bar'
require 'SVG/Graph/BarHorizontal'
require 'digest/sha1'
require_dependency 'open_project/scm/adapters'

class ChangesetNotFound < StandardError
end
class InvalidRevisionParam < StandardError
end

class RepositoriesController < ApplicationController
  include PaginationHelper
  include RepositoriesHelper

  menu_item :repository
  menu_item :settings, only: [:edit, :destroy_info]
  default_search_scope :changesets

  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_repository, except: [:edit, :update, :create, :destroy, :destroy_info]
  accept_key_auth :revisions

  rescue_from OpenProject::Scm::Exceptions::ScmError, with: :show_error_command_failed

  def edit
    service = Scm::RepositoryFactoryService.new(@project, params)
    if service.build_temporary
      @repository = service.repository
    else
      logger.error("Cannot create repository for #{params[:scm_vendor]}")
      flash.now[:error] = service.build_error
    end

    respond_to do |format|
      format.js { render 'repositories/settings/repository_form' }
    end
  end

  def update
    @repository = @project.repository
    update_repository(params.fetch(:repository, {}))
    respond_to do |format|
      format.js { render 'repositories/settings/repository_form' }
    end
  end

  def create
    service = Scm::RepositoryFactoryService.new(@project, params)
    if service.build_and_save
      @repository = service.repository
      flash[:notice] = l('repositories.create_successful')
      flash[:notice] << (' ' + l('repositories.create_managed_delay')) if @repository.managed?
    else
      flash[:error] = service.build_error
    end

    respond_to do |format|
      format.js { render js: "window.location = '#{settings_repository_tab_path}'" }
    end
  end

  def committers
    @committers = @repository.committers
    @users = @project.users.to_a
    additional_user_ids = @committers.map(&:last).map(&:to_i) - @users.map(&:id)
    @users += User.where(id: additional_user_ids) unless additional_user_ids.empty?
    @users.compact!
    @users.sort!
    if request.post? && params.key?(:committers)
      # Build a hash with repository usernames as keys and corresponding user ids as values
      @repository.committer_ids = params[:committers].values
        .inject({}) { |h, c|
          h[c.first] = c.last
          h
        }
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'committers', project_id: @project
    end
  end

  def destroy_info
    @repository = @project.repository
    @back_link = settings_repository_tab_path
  end

  def destroy
    repository = @project.repository
    if repository.destroy
      flash[:notice] = I18n.t('repositories.delete_sucessful')
    else
      flash[:error] = repository.errors.full_messages
    end
    redirect_to settings_repository_tab_path
  end

  def show
    if Setting.autofetch_changesets? && @path.blank?
      @repository.fetch_changesets
      @repository.update_required_storage
    end

    @limit = Setting.repository_truncate_at
    @entries = @repository.entries(@path, @rev, limit: @limit)
    @changeset = @repository.find_changeset_by_name(@rev)

    if request.xhr?
      if @entries && @repository.valid?
        render(partial: 'dir_list_content')
      else
        render(nothing: true)
      end
    elsif @entries.nil? && @repository.invalid?
      show_error_not_found
    else
      @changesets = @repository.latest_changesets(@path, @rev)
      @properties = @repository.properties(@path, @rev)
      render action: 'show'
    end
  end

  alias_method :browse, :show

  def changes
    @entry = @repository.entry(@path, @rev)

    unless @entry
      show_error_not_found
      return
    end

    @changesets = @repository.latest_changesets(@path,
                                                @rev,
                                                Setting.repository_log_display_limit.to_i)
    @properties = @repository.properties(@path, @rev)
    @changeset  = @repository.find_changeset_by_name(@rev)

    render 'changes', formats: [:html]
  end

  def revisions
    @changesets = @repository.changesets
                  .includes(:user, :repository)
                  .page(params[:page])
                  .per_page(per_page_param)

    respond_to do |format|
      format.html do
        render layout: false if request.xhr?
      end
      format.atom do
        render_feed(@changesets, title: "#{@project.name}: #{l(:label_revision_plural)}")
      end
    end
  end

  def entry
    @entry = @repository.entry(@path, @rev)
    unless @entry
      show_error_not_found
      return
    end

    # If the entry is a dir, show the browser
    if @entry.dir?
      show
      return
    end

    @content = @repository.cat(@path, @rev)

    unless @content
      show_error_not_found
      return
    end

    if raw_or_to_large_or_non_text(@content, @path)
      send_raw(@content, @path)
    else
      render_text_entry
    end
  end

  def is_entry_text_data?(ent, path)
    # UTF-16 contains "\x00".
    # It is very strict that file contains less than 30% of ascii symbols
    # in non Western Europe.
    return true if Redmine::MimeType.is_type?('text', path)
    # Ruby 1.8.6 has a bug of integer divisions.
    # http://apidock.com/ruby/v1_8_6_287/String/is_binary_data%3F
    if ent.respond_to?('is_binary_data?') && ent.is_binary_data? # Ruby 1.8.x and <1.9.2
      return false
    elsif ent.respond_to?(:force_encoding) &&
          (ent.dup.force_encoding('UTF-8') != ent.dup.force_encoding('BINARY')) # Ruby 1.9.2
      # TODO: need to handle edge cases of non-binary content that isn't UTF-8
      return false
    end
    true
  end

  private :is_entry_text_data?

  def annotate
    @entry = @repository.entry(@path, @rev)

    unless @entry
      show_error_not_found
      return
    end

    @annotate  = @repository.scm.annotate(@path, @rev)
    @changeset = @repository.find_changeset_by_name(@rev)

    render 'annotate', formats: [:html]
  end

  def revision
    raise ChangesetNotFound if @rev.blank?
    @changeset = @repository.find_changeset_by_name(@rev)
    raise ChangesetNotFound unless @changeset

    respond_to do |format|
      format.html
      format.js do render layout: false end
    end
  rescue ChangesetNotFound
    show_error_not_found
  end

  def diff
    if params[:format] == 'diff'
      @diff = @repository.diff(@path, @rev, @rev_to)

      unless @diff
        show_error_not_found
        return
      end

      filename = "changeset_r#{@rev}"
      filename << "_r#{@rev_to}" if @rev_to
      send_data @diff.join,
                filename: "#{filename}.diff",
                type: 'text/x-patch',
                disposition: 'attachment'
    else
      @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
      @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)

      # Save diff type as user preference
      if User.current.logged? && @diff_type != User.current.pref[:diff_type]
        User.current.pref[:diff_type] = @diff_type
        User.current.preference.save
      end

      @cache_key = "repositories/diff/#{@repository.id}/" +
                   Digest::MD5.hexdigest("#{@path}-#{@rev}-#{@rev_to}-#{@diff_type}")

      unless read_fragment(@cache_key)
        @diff = @repository.diff(@path, @rev, @rev_to)
        show_error_not_found unless @diff
      end

      @changeset = @repository.find_changeset_by_name(@rev)
      @changeset_to = @rev_to ? @repository.find_changeset_by_name(@rev_to) : nil
      @diff_format_revisions = @repository.diff_format_revisions(@changeset, @changeset_to)

      render 'diff', formats: :html
    end
  end

  def stats
    @show_commits_per_author = current_user.allowed_to_in_project?(:view_commit_author_statistics,
                                                                   @project)
  end

  def graph
    data = nil
    case params[:graph]
    when 'commits_per_month'
      data = graph_commits_per_month(@repository)
    when 'commits_per_author'
      unless current_user.allowed_to_in_project?(:view_commit_author_statistics, @project)
        return deny_access
      end
      data = graph_commits_per_author(@repository)
    end

    if data
      headers['Content-Type'] = 'image/svg+xml'
      send_data(data, type: 'image/svg+xml', disposition: 'inline')
    else
      render_404
    end
  end

  private

  REV_PARAM_RE = %r{\A[a-f0-9]*\Z}i

  def update_repository(repo_params)
    @repository.attributes = @repository.class.permitted_params(repo_params)

    if @repository.save
      flash.now[:notice] = l('repositories.update_settings_successful')
    else
      flash.now[:error] = @repository.errors.full_messages.join('\n')
    end
  end

  def find_repository
    @repository = @project.repository

    unless @repository
      render_404
      return false
    end

    # Prepare checkout instructions
    # available on all pages (even empty!)
    @path = params[:path] || ''
    @instructions = ::Scm::CheckoutInstructionsService.new(@repository, path: @path)

    # Asserts repository availability, or renders an appropriate error
    @repository.scm.check_availability!

    @rev = params[:rev].blank? ? @repository.default_branch : params[:rev].to_s.strip
    @rev_to = params[:rev_to]

    unless @rev.to_s.match(REV_PARAM_RE) && @rev_to.to_s.match(REV_PARAM_RE)
      if @repository.branches.blank?
        raise InvalidRevisionParam
      end
    end
  rescue OpenProject::Scm::Exceptions::ScmEmpty
    render 'empty'
  rescue ActiveRecord::RecordNotFound
    render_404
  rescue InvalidRevisionParam
    show_error_not_found
  end

  def show_error_not_found
    render_error message: l(:error_scm_not_found), status: 404
  end

  def show_error_command_failed(exception)
    render_error l(:error_scm_command_failed, exception.message)
  end

  def graph_commits_per_month(repository)
    @date_to = Date.today
    @date_from = @date_to << 11
    @date_from = Date.civil(@date_from.year, @date_from.month, 1)
    commits_by_day = Changeset.where(
      ['repository_id = ? AND commit_date BETWEEN ? AND ?', repository.id, @date_from, @date_to]
    ).group(:commit_date).size
    commits_by_month = [0] * 12
    commits_by_day.each do |c|
      commits_by_month[(@date_to.month - c.first.to_date.month) % 12] += c.last
    end

    changes_by_day = Change.includes(:changeset)
                     .where(["#{Changeset.table_name}.repository_id = ? "\
                             "AND #{Changeset.table_name}.commit_date BETWEEN ? AND ?",
                             repository.id, @date_from, @date_to])
                     .references(:changesets)
                     .group(:commit_date)
                     .size
    changes_by_month = [0] * 12
    changes_by_day.each do |c|
      changes_by_month[(@date_to.month - c.first.to_date.month) % 12] += c.last
    end

    fields = []
    12.times do |m|
      fields << month_name(((Date.today.month - 1 - m) % 12) + 1)
    end

    graph = SVG::Graph::Bar.new(
      height: 300,
      width: 800,
      fields: fields.reverse,
      stack: :side,
      scale_integers: true,
      step_x_labels: 2,
      show_data_values: false,
      graph_title: l(:label_commits_per_month),
      show_graph_title: true
    )

    graph.add_data(
      data: commits_by_month[0..11].reverse,
      title: l(:label_revision_plural)
    )

    graph.add_data(
      data: changes_by_month[0..11].reverse,
      title: l(:label_change_plural)
    )

    graph.burn
  end

  def graph_commits_per_author(repository)
    commits_by_author = Changeset.where(['repository_id = ?', repository.id]).group(:committer).size
    commits_by_author.to_a.sort! do |x, y|
      x.last <=> y.last
    end

    changes_by_author = Change.includes(:changeset)
                        .where(["#{Changeset.table_name}.repository_id = ?", repository.id])
                        .references(:changesets)
                        .group(:committer)
                        .size
    h = changes_by_author.inject({}) { |o, i|
      o[i.first] = i.last
      o
    }

    fields = commits_by_author.map(&:first)
    commits_data = commits_by_author.map(&:last)
    changes_data = commits_by_author.map { |r| h[r.first] || 0 }

    fields = fields + [''] * (10 - fields.length) if fields.length < 10
    commits_data = commits_data + [0] * (10 - commits_data.length) if commits_data.length < 10
    changes_data = changes_data + [0] * (10 - changes_data.length) if changes_data.length < 10

    # Remove email adress in usernames
    fields = fields.map { |c| c.gsub(%r{<.+@.+>}, '') }

    graph = SVG::Graph::BarHorizontal.new(
      height: 400,
      width: 800,
      fields: fields,
      stack: :side,
      scale_integers: true,
      show_data_values: false,
      rotate_y_labels: false,
      graph_title: l(:label_commits_per_author),
      show_graph_title: true
    )
    graph.add_data(
      data: commits_data,
      title: l(:label_revision_plural)
    )
    graph.add_data(
      data: changes_data,
      title: l(:label_change_plural)
    )
    graph.burn
  end

  def login_back_url_params
    params.permit(:path)
  end

  def raw_or_to_large_or_non_text(content, path)
    params[:format] == 'raw' ||
      (content.size && content.size > Setting.file_max_size_displayed.to_i.kilobyte) ||
      !is_entry_text_data?(content, path)
  end

  def send_raw(content, path)
    # Force the download
    send_opt = { filename: filename_for_content_disposition(path.split('/').last) }
    send_type = Redmine::MimeType.of(path)
    send_opt[:type] = send_type.to_s if send_type
    send_data content, send_opt
  end

  def render_text_entry
    # Prevent empty lines when displaying a file with Windows style eol
    # TODO: UTF-16
    # Is this needs? AttachmentsController reads file simply.
    @content.gsub!("\r\n", "\n")
    @changeset = @repository.find_changeset_by_name(@rev)

    # Forcing html format here to avoid
    # rails looking for e.g text when .txt is asked for
    render 'entry', formats: [:html]
  end
end

class Date
  def months_ago(date = Date.today)
    (date.year - year) * 12 + (date.month - month)
  end

  def weeks_ago(date = Date.today)
    (date.year - year) * 52 + (date.cweek - cweek)
  end
end

class String
  def with_leading_slash
    starts_with?('/') ? self : "/#{self}"
  end
end
