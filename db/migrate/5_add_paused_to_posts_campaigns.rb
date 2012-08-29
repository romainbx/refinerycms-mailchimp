class AddPausedToPostsCampaigns < ActiveRecord::Migration
  def self.up
    add_column :refinery_mailchimp_posts_campaigns, :paused, :boolean
  end

  def self.down
    remove_column :refinery_mailchimp_posts_campaigns, :paused
  end
end

