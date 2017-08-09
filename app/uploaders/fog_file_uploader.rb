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

require 'carrierwave/storage/fog'

class FogFileUploader < CarrierWave::Uploader::Base
  include FileUploader

  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def remote_file
    @remote_file || file
  end

  def local_file
    @remote_file ||= file
    cache_stored_file!
    super
  end

  def download_url
    remote_file.url
  end

  ##
  # Checks if this file exists and is readable in the remote storage.
  #
  # In the current version of carrierwave the call to #exists?
  # throws an error if the file does not exist:
  #
  #   Excon::Errors::Forbidden: Expected(200) <=> Actual(403 Forbidden)
  def readable?
    remote_file.exists?
  rescue Excon::Errors::Forbidden
    false
  end
end
