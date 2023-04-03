class ChangeSalaryDataTypeInJobs < ActiveRecord::Migration[7.0]
  def change
    change_column :jobs, :salary, :string
  end
end
