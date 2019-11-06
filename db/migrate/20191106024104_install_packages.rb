class InstallPackages < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS plpgsql;"
  end

  def down
    execute "DROP EXTENSION IF EXISTS plpgsql;"
  end
end