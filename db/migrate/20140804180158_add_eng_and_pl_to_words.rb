class AddEngAndPlToWords < ActiveRecord::Migration
  def change
  	add_column :words, :eng, :string
  	add_column :words, :pl, :string
  end

end
