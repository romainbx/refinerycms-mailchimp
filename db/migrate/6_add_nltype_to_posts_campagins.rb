class AddNltypeToPostsCampaigns < ActiveRecord::Migration
  def self.up
    add_column :refinery_mailchimp_posts_campaigns, :nltype, :integer
  end

  def self.down
    remove_column :refinery_mailchimp_posts_campaigns, :nltype
  end
end

