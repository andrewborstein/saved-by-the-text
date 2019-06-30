class CreateTexts < ActiveRecord::Migration[5.2]
  def change
    create_table :texts do |t|
      t.string :num
      t.text :msg

      t.timestamps null: false
    end
  end
end
