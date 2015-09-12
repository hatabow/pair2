class CreateRecordings < ActiveRecord::Migration
  def change
    create_table :recordings do |t|
      t.string :url

      t.timestamps null: false
    end
  end
end
