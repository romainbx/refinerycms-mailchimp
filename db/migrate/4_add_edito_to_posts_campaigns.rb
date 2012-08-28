
class AddEditoToPostsCampaigns < ActiveRecord::Migration

  def up
    add_column :refinery_mailchimp_posts_campaigns, :edito_id, :integer
  end

  def self.down
    remove_column :refinery_mailchimp_posts_campaigns, :edito_id, :integer
  end

end
