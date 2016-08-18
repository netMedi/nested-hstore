class CreatePosts < ActiveRecord::Migration
  def self.up
    execute "CREATE EXTENSION IF NOT EXISTS hstore"
    create_table :posts do |t|
      t.string :title
      t.hstore :properties
      t.hstore :properties_with_default, default: {}, null: false
    end
  end

  def self.down
    drop_table :posts
  end
end
