class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.string :charity
      t.integer :salary
      t.date :closes
      t.string :url

      t.timestamps
    end
  end
end
