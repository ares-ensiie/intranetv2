class AddSuperAppToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :super_app, :boolean
  end
end
