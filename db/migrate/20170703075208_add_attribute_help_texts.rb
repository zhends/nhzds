class AddAttributeHelpTexts < ActiveRecord::Migration[5.0]
  def change
    create_table :attribute_help_texts do |t|
      t.text :help_text, null: false
      t.string :type, null: false
      t.string :attribute_name, null: false

      t.timestamps
    end
  end
end
