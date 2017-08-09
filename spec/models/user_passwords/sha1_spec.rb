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

require 'spec_helper'

describe UserPassword::SHA1, type: :model do
  let(:legacy_password) {
    pass = FactoryGirl.build(:legacy_sha1_password, plain_password: 'adminAdmin!')
    expect(pass).to receive(:salt_and_hash_password!).and_return nil

    pass.save!
    pass
  }

  describe '#matches_plaintext?' do
    it 'still matches for existing passwords' do
      expect(legacy_password).to be_a(UserPassword::SHA1)
      expect(legacy_password.matches_plaintext?('adminAdmin!')).to be_truthy
    end
  end

  describe '#create' do
    let(:legacy_password) { FactoryGirl.build(:legacy_sha1_password) }

    it 'raises an exception trying to save it' do
      expect { legacy_password.save! }.to raise_error(ArgumentError)
    end
  end
end
