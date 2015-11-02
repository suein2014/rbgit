class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :keyword
      t.text :content
      t.integer :source

      t.timestamps null: false
    end
    add_column :articles, :category_id, :integer
  end
end
