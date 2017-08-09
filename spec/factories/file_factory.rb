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

FactoryGirl.define do
  ##
  # Yields fixture files.
  factory :file, class: File do
    # Skip the create callback to be able to use non-AR models. Otherwise FactoryGirl will
    # try to call #save! on any created object.
    skip_create

    name 'textfile.txt'

    initialize_with do
      new "#{Rails.root}/spec/fixtures/files/#{name}"
    end
  end

  factory :uploaded_file, class: Rack::Multipart::UploadedFile do
    skip_create

    name 'test.txt'
    content 'test content'
    content_type 'text/plain'
    binary false

    initialize_with do
      FileHelpers.mock_uploaded_file(
        name:         name,
        content:      content,
        content_type: content_type,
        binary:       binary)
    end

    factory :uploaded_jpg do
      name 'test.jpg'
      content "\xFF\xD8\xFF\xE0\u0000\u0010JFIF\u0000\u0001\u0001\u0001\u0000H"
      content_type 'image/jpeg'
      binary true
    end
  end
end
