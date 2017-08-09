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

# This file includes UTF-8 "Felix Schäfer".
# We need to consider Ruby 1.9 compatibility.

require 'legacy_spec_helper'

describe OpenProject::Scm::Adapters::Git, type: :model do
  let(:git_repository_path) {  Rails.root.to_s.gsub(%r{config\/\.\.}, '') + '/tmp/test/git_repository' }

  FELIX_UTF8 = 'Felix Schäfer'
  FELIX_HEX  = "Felix Sch\xC3\xA4fer"
  CHAR_1_HEX = "\xc3\x9c"

  ## Ruby uses ANSI api to fork a process on Windows.
  ## Japanese Shift_JIS and Traditional Chinese Big5 have 0x5c(backslash) problem
  ## and these are incompatible with ASCII.
  # WINDOWS_PASS1 = Redmine::Platform.mswin?
  WINDOWS_PASS1 = false

  before do
    skip 'Git test repository NOT FOUND. Skipping unit tests !!!' unless File.directory?(git_repository_path)

    @adapter = OpenProject::Scm::Adapters::Git.new(
      git_repository_path,
      nil,
      nil,
      nil,
      'ISO-8859-1'
    )
    assert @adapter
    @char_1        = CHAR_1_HEX.dup
    if @char_1.respond_to?(:force_encoding)
      @char_1.force_encoding('UTF-8')
    end
  end

  it 'should scm version' do
    to_test = { "git version 1.7.3.4\n"             => [1, 7, 3, 4],
                "1.6.1\n1.7\n1.8"                   => [1, 6, 1],
                "1.6.2\r\n1.8.1\r\n1.9.1"           => [1, 6, 2] }
    to_test.each do |s, v|
      test_scm_version_for(s, v)
    end
  end

  it 'should branches' do
    assert_equal [
      'latin-1-path-encoding',
      'master',
      'test-latin-1',
      'test_branch',
    ], @adapter.branches
  end

  it 'should tags' do
    assert_equal [
      'tag00.lightweight',
      'tag01.annotated',
    ], @adapter.tags
  end

  it 'should getting all revisions' do
    assert_equal 22, @adapter.revisions('', nil, nil, all: true).length
  end

  it 'should getting certain revisions' do
    assert_equal 1, @adapter.revisions('', '899a15d^', '899a15d').length
  end

  it 'should revisions reverse' do
    revs1 = @adapter.revisions('', nil, nil, all: true, reverse: true)
    assert_equal 22, revs1.length
    assert_equal '7234cb2750b63f47bff735edc50a1c0a433c2518', revs1[0].identifier
    assert_equal '1ca7f5ed374f3cb31a93ae5215c2e25cc6ec5127', revs1[20].identifier

    since2 = Time.gm(2010, 9, 30, 0, 0, 0)
    revs2 = @adapter.revisions('', nil, nil, all: true, since: since2, reverse: true)
    assert_equal 7, revs2.length
    assert_equal '67e7792ce20ccae2e4bb73eed09bb397819c8834', revs2[0].identifier
    assert_equal '1ca7f5ed374f3cb31a93ae5215c2e25cc6ec5127', revs2[5].identifier
    assert_equal '71e5c1d3dca6304805b143b9d0e6695fb3895ea4', revs2[6].identifier
  end

  it 'should getting revisions with spaces in filename' do
    assert_equal 1, @adapter.revisions('filemane with spaces.txt',
                                       nil, nil, all: true).length
  end

  it 'should getting revisions with leading and trailing spaces in filename' do
    assert_equal ' filename with a leading space.txt ',
                 @adapter.revisions(' filename with a leading space.txt ',
                                    nil, nil, all: true)[0].paths[0][:path]
  end

  it 'should getting entries with leading and trailing spaces in filename' do
    assert_equal ' filename with a leading space.txt ',
                 @adapter.entries('',
                                  '83ca5fd546063a3c7dc2e568ba3355661a9e2b2c')[3].name
  end

  it 'should annotate' do
    annotate = @adapter.annotate('sources/watchers_controller.rb')
    assert_kind_of OpenProject::Scm::Adapters::Annotate, annotate
    assert_equal 41, annotate.lines.size
    assert_equal '# This program is free software; you can redistribute it and/or',
                 annotate.lines[4].strip
    assert_equal '7234cb2750b63f47bff735edc50a1c0a433c2518',
                 annotate.revisions[4].identifier
    assert_equal 'jsmith', annotate.revisions[4].author
  end

  it 'should annotate moved file' do
    annotate = @adapter.annotate('renamed_test.txt')
    assert_kind_of OpenProject::Scm::Adapters::Annotate, annotate
    assert_equal 2, annotate.lines.size
  end

  it 'should last rev' do
    last_rev = @adapter.lastrev('README',
                                '4f26664364207fa8b1af9f8722647ab2d4ac5d43')
    assert_equal '4a07fe31bffcf2888791f3e6cbc9c4545cefe3e8', last_rev.scmid
    assert_equal '4a07fe31bffcf2888791f3e6cbc9c4545cefe3e8', last_rev.identifier
    assert_equal 'Adam Soltys <asoltys@gmail.com>', last_rev.author
    assert_equal '2009-06-24 05:27:38 +0000'.to_time, last_rev.time
  end

  it 'should last rev with spaces in filename' do
    last_rev = @adapter.lastrev('filemane with spaces.txt',
                                'ed5bb786bbda2dee66a2d50faf51429dbc043a7b')
    str_felix_utf8 = FELIX_UTF8.dup
    str_felix_hex  = FELIX_HEX.dup
    last_rev_author = last_rev.author
    if last_rev_author.respond_to?(:force_encoding)
      last_rev_author.force_encoding('UTF-8')
    end
    assert_equal 'ed5bb786bbda2dee66a2d50faf51429dbc043a7b', last_rev.scmid
    assert_equal 'ed5bb786bbda2dee66a2d50faf51429dbc043a7b', last_rev.identifier
    assert_equal "#{str_felix_utf8} <felix@fachschaften.org>",
                 last_rev.author
    assert_equal "#{str_felix_hex} <felix@fachschaften.org>",
                 last_rev.author
    assert_equal '2010-09-18 19:59:46 +0000'.to_time, last_rev.time
  end

  it 'test latin 1 path' do
    if WINDOWS_PASS1
      #
    else
      p2 = "latin-1-dir/test-#{@char_1}-2.txt"
      ['4fc55c43bf3d3dc2efb66145365ddc17639ce81e', '4fc55c43bf3'].each do |r1|
        assert @adapter.diff(p2, r1)
        assert @adapter.cat(p2, r1)
        annotation = @adapter.annotate(p2, r1)
        assert annotation.present?, 'No annotation returned'
        assert_equal 1, annotation.lines.length
        ['64f1f3e89ad1cb57976ff0ad99a107012ba3481d', '64f1f3e89ad1cb5797'].each do |r2|
          assert @adapter.diff(p2, r1, r2)
        end
      end
    end
  end

  it 'should entries tag' do
    entries1 = @adapter.entries(nil, 'tag01.annotated')
    assert entries1
    assert_equal 3, entries1.size
    assert_equal 'sources', entries1[1].name
    assert_equal 'sources', entries1[1].path
    assert_equal 'dir', entries1[1].kind
    readme = entries1[2]
    assert_equal 'README', readme.name
    assert_equal 'README', readme.path
    assert_equal 'file', readme.kind
    assert_equal 27, readme.size
    assert_equal '899a15dba03a3b350b89c3f537e4bbe02a03cdc9', readme.lastrev.identifier
    assert_equal Time.gm(2007, 12, 14, 9, 24, 1), readme.lastrev.time
  end

  it 'should entries branch' do
    entries1 = @adapter.entries(nil, 'test_branch')
    assert entries1
    assert_equal 4, entries1.size
    assert_equal 'sources', entries1[1].name
    assert_equal 'sources', entries1[1].path
    assert_equal 'dir', entries1[1].kind
    readme = entries1[2]
    assert_equal 'README', readme.name
    assert_equal 'README', readme.path
    assert_equal 'file', readme.kind
    assert_equal 159, readme.size
    assert_equal '713f4944648826f558cf548222f813dabe7cbb04', readme.lastrev.identifier
    assert_equal Time.gm(2009, 6, 19, 4, 37, 23), readme.lastrev.time
  end

  it 'should entries latin 1 files' do
    entries1 = @adapter.entries('latin-1-dir', '64f1f3e8')
    assert entries1
    assert_equal 3, entries1.size
    f1 = entries1[1]
    assert_equal "test-#{@char_1}-2.txt", f1.name
    assert_equal "latin-1-dir/test-#{@char_1}-2.txt", f1.path
    assert_equal 'file', f1.kind
  end

  it 'should entries latin 1 dir' do
    if WINDOWS_PASS1
      #
    else
      entries1 = @adapter.entries("latin-1-dir/test-#{@char_1}-subdir",
                                  '1ca7f5ed')
      assert entries1
      assert_equal 3, entries1.size
      f1 = entries1[1]
      assert_equal "test-#{@char_1}-2.txt", f1.name
      assert_equal "latin-1-dir/test-#{@char_1}-subdir/test-#{@char_1}-2.txt", f1.path
      assert_equal 'file', f1.kind
    end
  end

  private

  def test_scm_version_for(scm_command_version, version)
    expect(@adapter).to receive(:scm_version_from_command_line).and_return(scm_command_version)
    assert_equal version, @adapter.git_binary_version
  end
end
