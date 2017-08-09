#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
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
module RandomData
  class WikiSeeder
    def self.seed!(project)
      user = User.admin.first

      puts ''
      print ' ↳ Creating wikis'

      rand(5).times do
        print '.'
        wiki_page = WikiPage.create(
          wiki:  project.wiki,
          title: Faker::Lorem.words(5).join(' ')
        )

        ## create some wiki contents
        rand(5).times do
          print '.'
          wiki_content = WikiContent.create(
            page:    wiki_page,
            author:  user,
            text:    Faker::Lorem.paragraph(5, true, 3)
          )

          ## create some journal entries
          rand(5).times do
            wiki_content.reload
            wiki_content.text = Faker::Lorem.paragraph(5, true, 3) if rand(99).even?
            wiki_content.save!
          end
        end
      end
    end
  end
end
