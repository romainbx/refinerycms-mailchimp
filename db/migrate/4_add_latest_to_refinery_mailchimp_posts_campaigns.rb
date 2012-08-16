class AddLatestToRefineryMailchimpPostsCampaigns < ActiveRecord::Migration
  
  def change
    add_column :refinery_mailchimp_posts_campaigns, :latest, :boolean
  end

end
