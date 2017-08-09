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

require 'spec_helper'

describe OpenProject::FormTagHelper, type: :helper do
  let(:options) { {} }

  describe '#styled_form_tag' do
    subject(:output) {
      helper.styled_form_tag('/feedback', options) do
        content_tag(:p, 'Form content')
      end
    }

    it_behaves_like 'not wrapped in container', 'form-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <form accept-charset="UTF-8" action="/feedback" class="form"
          method="post"><input name="utf8"
          type="hidden" value="&#x2713;" /><p>Form content</p></form>
      })
    end
  end

  describe '#styled_select_tag' do
    subject(:output) {
      helper.styled_select_tag('field', '<option value="33">FUN</option>'.html_safe, options)
    }

    it_behaves_like 'wrapped in container', 'select-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <select class="form--select"
          id="field" name="field"><option value="33">FUN</option></select>
      }).at_path('select')
    end
  end

  describe '#styled_text_field_tag' do
    let(:value) { 'Something to be seen' }

    subject(:output) {
      helper.styled_text_field_tag('field', value, options)
    }

    it_behaves_like 'wrapped in container', 'text-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--text-field"
          id="field" name="field" type="text" value="Something to be seen" />
      }).at_path('input')
    end
  end

  describe '#styled_label_tag' do
    context 'with block' do
      subject(:output) {
        helper.styled_label_tag('field', nil, options) do
          'Label content'
        end
      }

      it_behaves_like 'not wrapped in container', 'label-container'

      it 'should output element' do
        expect(output).to be_html_eql(%{
          <label class="form--label" for="field" title="Label content">Label content</label>
        })
      end
    end

    context 'with content arg' do
      subject(:output) {
        helper.styled_label_tag('field', 'Label content', options)
      }

      it_behaves_like 'not wrapped in container', 'label-container'

      it 'should output element' do
        expect(output).to be_html_eql(%{
          <label class="form--label" for="field" title="Label content">Label content</label>
        })
      end
    end

    context 'titles' do
      it 'should use the title from the options if given' do
        label = helper.styled_label_tag 'field', 'Lautrec', title: 'Carim'
        expect(label).to be_html_eql(%{
          <label for="field" class="form--label" title="Carim">Lautrec</label>
        })
      end

      it 'should prefer the title given in the options over the content' do
        label = helper.styled_label_tag('field', nil, title: 'Carim') { 'Lordvessel' }
        expect(label).to be_html_eql(%{
          <label for="field" class="form--label" title="Carim">Lordvessel</label>
        })
      end

      it 'should strip any given inline HTML from the title tag (with block)' do
        label = helper.styled_label_tag('field') {
          helper.content_tag :span, 'Sif'
        }
        expect(label).to be_html_eql(%{
          <label for="field" class="form--label" title="Sif"><span>Sif</span></label>
        })
      end

      it 'should strip any given inline HTML from the title tag (with content arg)' do
        label = helper.styled_label_tag('field', helper.content_tag(:span, 'Sif'))
        expect(label).to be_html_eql(%{
          <label for="field" class="form--label" title="Sif"><span>Sif</span></label>
        })
      end
    end
  end

  describe '#styled_file_field_tag' do
    subject(:output) {
      helper.styled_file_field_tag('file_field', options)
    }

    it_behaves_like 'wrapped in container', 'file-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--file-field"
          id="file_field" name="file_field" type="file" />
      }).at_path('input')
    end
  end

  describe '#styled_password_field_tag' do
    subject(:output) {
      helper.styled_password_field_tag('password', 'nopE3king!', options)
    }

    it_behaves_like 'wrapped in container', 'text-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--text-field -password"
          id="password" name="password" type="password" value="nopE3king!" />
      }).at_path('input')
    end
  end

  describe '#styled_text_area_tag' do
    subject(:output) {
      helper.styled_text_area_tag('field', 'Words are important', options)
    }

    it_behaves_like 'wrapped in container', 'text-area-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <textarea class="form--text-area" id="field" name="field">
Words are important</textarea>
      }).at_path('textarea')
    end
  end

  describe '#styled_check_box_tag' do
    subject(:output) {
      helper.styled_check_box_tag('field', '1', false, options)
    }

    it_behaves_like 'wrapped in container', 'check-box-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--check-box"
          id="field" name="field" type="checkbox" value="1" />
      }).at_path('input')
    end
  end

  describe '#styled_radio_button_tag' do
    let(:value) { 'good choice' }

    subject(:output) {
      helper.styled_radio_button_tag('field', value, false, options)
    }

    it_behaves_like 'wrapped in container', 'radio-button-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--radio-button"
          id="field_good_choice" name="field" type="radio" value="good choice" />
      }).at_path('input')
    end
  end

  describe '#styled_submit_tag' do
    subject(:output) {
      helper.styled_submit_tag('Save it!', options)
    }
    subject(:html) {
      Capybara::Node::Simple.new(output)
    }

    it_behaves_like 'not wrapped in container', 'submit-container'

    it 'should output element' do
      expect(html).to have_selector('input[type=submit]')
    end
  end

  describe '#styled_button_tag' do
    subject(:output) {
      helper.styled_button_tag(options) do
        "Don't save!"
      end
    }

    it_behaves_like 'not wrapped in container', 'button-container'

    it 'should output element' do
      expect(output).to be_html_eql %{
        <button class="button" name="button" type="submit">Don&#x27;t save!</button>
      }
    end
  end

  describe '#styled_field_set_tag' do
    subject(:output) {
      helper.styled_field_set_tag('Fieldset Legend', options) do
        content_tag(:p, 'Fieldset content')
      end
    }

    it_behaves_like 'not wrapped in container', 'fieldset-container'

    it 'should output element' do
      expect(output).to be_html_eql %{
        <fieldset
          class="form--fieldset"><legend>Fieldset Legend</legend>
            <p>Fieldset content</p></fieldset>
      }
    end
  end

  describe '#styled_search_field_tag' do
    let(:value) { 'Find me' }

    subject(:output) {
      helper.styled_search_field_tag('field', value, options)
    }

    it_behaves_like 'wrapped in container', 'search-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--search-field"
          id="field" name="field" type="search" value="Find me" />
      }).at_path('input')
    end
  end

  describe '#styled_telephone_field_tag' do
    let(:value) { '+49 555 111 999' }

    subject(:output) {
      helper.styled_telephone_field_tag('field', value, options)
    }

    it_behaves_like 'wrapped in container', 'text-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--text-field -telephone"
          id="field" name="field" type="tel" value="+49 555 111 999" />
      }).at_path('input')
    end
  end

  describe '#styled_url_field_tag' do
    let(:value) { 'https://blogger.org/' }

    subject(:output) {
      helper.styled_url_field_tag('field', value, options)
    }

    it_behaves_like 'wrapped in container', 'text-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--text-field -url"
          id="field" name="field" type="url" value="https://blogger.org/" />
      }).at_path('input')
    end
  end

  describe '#styled_email_field_tag' do
    let(:value) { 'joe@blogger.com' }

    subject(:output) {
      helper.styled_email_field_tag('field', value, options)
    }

    it_behaves_like 'wrapped in container', 'text-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--text-field -email"
          id="field" name="field" type="email" value="joe@blogger.com" />
      }).at_path('input')
    end
  end

  describe '#styled_number_field_tag' do
    let(:value) { 2 }

    subject(:output) {
      helper.styled_number_field_tag('field', value, options)
    }

    it_behaves_like 'wrapped in container', 'text-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--text-field -number" id="field" name="field" type="number" value="2" />
      }).at_path('input')
    end
  end

  describe '#styled_range_field_tag' do
    let(:value) { 2 }

    subject(:output) {
      helper.styled_range_field_tag('field', value, options)
    }

    it_behaves_like 'wrapped in container', 'range-field-container'

    it 'should output element' do
      expect(output).to be_html_eql(%{
        <input class="form--range-field" id="field" name="field" type="range" value="2" />
      }).at_path('input')
    end
  end
end
