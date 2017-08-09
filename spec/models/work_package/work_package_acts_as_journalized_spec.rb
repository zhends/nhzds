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

describe WorkPackage, type: :model do
  describe '#journal' do
    let(:type) { FactoryGirl.create :type }
    let(:project) {
      FactoryGirl.create :project,
                         types: [type]
    }
    let(:status) { FactoryGirl.create :default_status }
    let(:priority) { FactoryGirl.create :priority }
    let(:work_package) {
      FactoryGirl.create(:work_package,
                         project_id: project.id,
                         type: type,
                         description: 'Description',
                         priority: priority)
    }
    let(:current_user) { FactoryGirl.create(:user) }

    before do
      allow(User).to receive(:current).and_return current_user

      work_package
    end

    context 'on work package creation' do
      it { expect(Journal.all.count).to eq(1) }

      it 'has a journal entry' do
        expect(Journal.first.journable).to eq(work_package)
      end
    end

    context 'nothing is changed' do
      before do work_package.save! end

      it { expect(Journal.all.count).to eq(1) }
    end

    context 'when the journal manager does not detect a change to be tracked' do
      before do
        allow(JournalManager).to receive(:changed?).with(work_package).and_return false
        work_package.assign_attributes subject: "#{work_package.subject} with changes"
      end

      it 'is not created' do
        expect { work_package.save! }.not_to change { work_package.journals.length }
      end
    end

    context 'different newlines' do
      let(:description) { "Description\n\nwith newlines\n\nembedded" }
      let(:changed_description) { description.gsub("\n", "\r\n") }
      let!(:work_package_1) {
        FactoryGirl.create(:work_package,
                           project_id: project.id,
                           type: type,
                           description: description,
                           priority: priority)
      }

      before do work_package_1.description = changed_description end

      context 'when a new journal is created tracking a simultaneously applied change' do
        before do
          work_package_1.subject += 'changed'
          work_package_1.save!
        end

        describe 'does not track the changed newline characters' do
          subject { work_package_1.journals.last.data.description }

          it { is_expected.to eq(description) }
        end

        describe 'tracks only the other change' do
          subject { work_package_1.journals.last.details }

          it { is_expected.to have_key :subject }
          it { is_expected.not_to have_key :description }
        end
      end

      context 'when there is a legacy journal containing non-escaped newlines' do
        let!(:work_package_journal_1) {
          FactoryGirl.create(:work_package_journal,
                             journable_id: work_package_1.id,
                             version: 2,
                             data: FactoryGirl.build(:journal_work_package_journal,
                                                     description: description))
        }
        let!(:work_package_journal_2) {
          FactoryGirl.create(:work_package_journal,
                             journable_id: work_package_1.id,
                             version: 3,
                             data: FactoryGirl.build(:journal_work_package_journal,
                                                     description: changed_description))
        }

        subject { work_package_1.journals.last.details }

        it { is_expected.not_to have_key :description }
      end
    end

    context 'on work package change' do
      let(:parent_work_package) {
        FactoryGirl.create(:work_package,
                           project_id: project.id,
                           type: type,
                           priority: priority)
      }
      let(:type_2) { FactoryGirl.create :type }
      let(:status_2) { FactoryGirl.create :status }
      let(:priority_2) { FactoryGirl.create :priority }

      before do
        project.types << type_2

        work_package.subject = 'changed'
        work_package.description = 'changed'
        work_package.type = type_2
        work_package.status = status_2
        work_package.priority = priority_2
        work_package.start_date = Date.new(2013, 1, 24)
        work_package.due_date = Date.new(2013, 1, 31)
        work_package.estimated_hours = 40.0
        work_package.assigned_to = User.current
        work_package.responsible = User.current
        work_package.parent = parent_work_package

        work_package.save!
      end

      context 'last created journal' do
        subject { work_package.journals.last.details }

        it 'contains all changes' do
          [:subject, :description, :type_id, :status_id, :priority_id,
           :start_date, :due_date, :estimated_hours, :assigned_to_id,
           :responsible_id, :parent_id].each do |a|
            expect(subject).to have_key(a.to_s), "Missing change for #{a}"
          end
        end
      end

      shared_examples_for 'old value' do
        subject { work_package.last_journal.old_value_for(property) }

        it { is_expected.to eq(expected_value) }
      end

      shared_examples_for 'new value' do
        subject { work_package.last_journal.new_value_for(property) }

        it { is_expected.to eq(expected_value) }
      end

      describe 'journaled value for' do
        context 'description' do
          let(:property) { 'description' }

          context 'old_value' do
            let(:expected_value) { 'Description' }

            it_behaves_like 'old value'
          end

          context 'new value' do
            let(:expected_value) { 'changed' }

            it_behaves_like 'new value'
          end
        end
      end

      describe 'adding journal with a missing journal and an existing journal' do
        before do
          allow(WorkPackages::UpdateContract).to receive(:new).and_return(NoopContract.new)
          service = UpdateWorkPackageService.new(user: current_user, work_package: work_package)
          service.call(attributes: { journal_notes: 'note to be deleted' })
          work_package.reload
          service.call(attributes: { description: 'description v2' })
          work_package.reload
          work_package.journals.find_by(notes: 'note to be deleted').delete

          service.call(attributes: { description: 'description v4' })
        end

        it 'should create a journal for the last change' do
          last_journal = work_package.journals.order(:id).last

          expect(last_journal.data.description).to eql('description v4')
        end
      end
    end

    context 'attachments' do
      let(:attachment) { FactoryGirl.build :attachment }
      let(:attachment_id) { "attachments_#{attachment.id}" }

      before do
        work_package.attachments << attachment
        work_package.save!
      end

      context 'new attachment' do
        subject { work_package.journals.last.details }

        it { is_expected.to have_key attachment_id }

        it { expect(subject[attachment_id]).to eq([nil, attachment.filename]) }
      end

      context 'attachment saved w/o change' do
        before do
          @original_journal_count = work_package.journals.count

          attachment.save!
        end

        subject { work_package.journals.count }

        it { is_expected.to eq(@original_journal_count) }
      end

      context 'attachment removed' do
        before do work_package.attachments.delete(attachment) end

        subject { work_package.journals.last.details }

        it { is_expected.to have_key attachment_id }

        it { expect(subject[attachment_id]).to eq([attachment.filename, nil]) }
      end
    end

    context 'custom values' do
      let(:custom_field) { FactoryGirl.create :work_package_custom_field }
      let(:custom_value) {
        FactoryGirl.create :custom_value,
                           value: 'false',
                           customized: work_package,
                           custom_field: custom_field
      }

      let(:custom_field_id) { "custom_fields_#{custom_value.custom_field_id}" }

      shared_context 'work package with custom value' do
        before do
          project.work_package_custom_fields << custom_field
          type.custom_fields << custom_field
          custom_value
          work_package.save!
        end
      end

      context 'new custom value' do
        include_context 'work package with custom value'

        subject { work_package.journals.last.details }

        it { is_expected.to have_key custom_field_id }

        it { expect(subject[custom_field_id]).to eq([nil, custom_value.value]) }
      end

      context 'custom value modified' do
        include_context 'work package with custom value'

        let(:modified_custom_value) {
          FactoryGirl.create :custom_value,
                             value: 'true',
                             custom_field: custom_field
        }
        before do
          work_package.custom_values = [modified_custom_value]
          work_package.save!
        end

        subject { work_package.journals.last.details }

        it { is_expected.to have_key custom_field_id }

        it { expect(subject[custom_field_id]).to eq([custom_value.value.to_s, modified_custom_value.value.to_s]) }
      end

      context 'work package saved w/o change' do
        include_context 'work package with custom value'

        let(:unmodified_custom_value) {
          FactoryGirl.create :custom_value,
                             value: 'false',
                             custom_field: custom_field
        }
        before do
          @original_journal_count = work_package.journals.count

          work_package.custom_values = [unmodified_custom_value]
          work_package.save!
        end

        subject { work_package.journals.count }

        it { is_expected.to eq(@original_journal_count) }
      end

      context 'custom value removed' do
        include_context 'work package with custom value'

        before do
          work_package.custom_values.delete(custom_value)
          work_package.save!
        end

        subject { work_package.journals.last.details }

        it { is_expected.to have_key custom_field_id }

        it { expect(subject[custom_field_id]).to eq([custom_value.value, nil]) }
      end

      context 'custom value did not exist before' do
        let(:custom_field) {
          FactoryGirl.create :work_package_custom_field,
                             is_required: false,
                             field_format: 'list',
                             possible_values: ['', '1', '2', '3', '4', '5', '6', '7']
        }
        let(:custom_value) {
          FactoryGirl.create :custom_value,
                             value: '',
                             customized: work_package,
                             custom_field: custom_field
        }

        describe 'empty values are recognized as unchanged' do
          include_context 'work package with custom value'

          it { expect(work_package.journals.last.customizable_journals).to be_empty }

          it { expect(JournalManager.changed? work_package).to be_falsey }
        end

        describe 'empty values handled as non existing' do
          include_context 'work package with custom value'

          it { expect(work_package.journals.last.customizable_journals.count).to eq(0) }
        end
      end
    end
  end

  describe 'Acts as journalized' do
    before(:each) do
      Status.delete_all
      IssuePriority.delete_all

      @type ||= FactoryGirl.create(:type_feature)

      @status_resolved ||= FactoryGirl.create(:status, name: 'Resolved', is_default: false)
      @status_open ||= FactoryGirl.create(:status, name: 'Open', is_default: true)
      @status_rejected ||= FactoryGirl.create(:status, name: 'Rejected', is_default: false)

      role = FactoryGirl.create(:role)
      FactoryGirl.create(:workflow,
                         old_status: @status_open,
                         new_status: @status_resolved,
                         role: role,
                         type_id: @type.id)
      FactoryGirl.create(:workflow,
                         old_status: @status_resolved,
                         new_status: @status_rejected,
                         role: role,
                         type_id: @type.id)

      @priority_low ||= FactoryGirl.create(:priority_low, is_default: true)
      @priority_high ||= FactoryGirl.create(:priority_high)
      @project ||= FactoryGirl.create(:project_with_types)

      @current = FactoryGirl.create(:user, login: 'user1', mail: 'user1@users.com')
      allow(User).to receive(:current).and_return(@current)
      @project.add_member!(@current, role)

      @user2 = FactoryGirl.create(:user, login: 'user2', mail: 'user2@users.com')

      @issue ||= FactoryGirl.create(:work_package,
                                    project: @project,
                                    status: @status_open,
                                    type: @type,
                                    author: @current)
    end

    describe 'ignore blank to blank transitions' do
      it 'should not include the "nil to empty string"-transition' do
        @issue.description = nil
        @issue.save!

        @issue.description = ''
        expect(@issue.send(:incremental_journal_changes)).to be_empty
      end
    end

    describe 'Acts as journalized recreate initial journal' do
      it 'should not include certain attributes' do
        recreated_journal = @issue.recreate_initial_journal!

        expect(recreated_journal.details.include?('rgt')).to eq(false)
        expect(recreated_journal.details.include?('lft')).to eq(false)
        expect(recreated_journal.details.include?('lock_version')).to eq(false)
        expect(recreated_journal.details.include?('updated_at')).to eq(false)
        expect(recreated_journal.details.include?('updated_on')).to eq(false)
        expect(recreated_journal.details.include?('id')).to eq(false)
        expect(recreated_journal.details.include?('type')).to eq(false)
        expect(recreated_journal.details.include?('root_id')).to eq(false)
      end

      it 'should not include useless transitions' do
        recreated_journal = @issue.recreate_initial_journal!

        recreated_journal.details.values.each do |change|
          expect(change.first).not_to eq(change.last)
        end
      end

      it 'should not be different from the initially created journal by aaj' do
        # Creating four journals total
        @issue.status = @status_resolved
        @issue.assigned_to = @user2
        @issue.save!
        @issue.reload

        @issue.priority = @priority_high
        @issue.save!
        @issue.reload

        @issue.status = @status_rejected
        @issue.priority = @priority_low
        @issue.estimated_hours = 3
        @issue.save!

        initial_journal = @issue.journals.first
        recreated_journal = @issue.recreate_initial_journal!

        expect(initial_journal).to be_identical(recreated_journal)
      end

      it 'should not validate with oddly set estimated_hours' do
        @issue.estimated_hours = 'this should not work'
        expect(@issue).not_to be_valid
      end

      it 'should validate with sane estimated_hours' do
        @issue.estimated_hours = '13h'
        expect(@issue).to be_valid
      end
    end
  end
end
