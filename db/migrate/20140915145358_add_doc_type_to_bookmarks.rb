class AddDocTypeToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :doc_type, :string
  end
end
