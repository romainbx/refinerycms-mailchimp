class CreateRefineryMailchimpWeeklyCampaigns < ActiveRecord::Migration

  def up
    create_table :refinery_mailchimp_weekly_campaigns do |t|
      t.string :subject, :mailchimp_campaign_id, :mailchimp_list_id, :mailchimp_template_id, :from_email, :from_name, :to_name
      t.text :body
      t.datetime :sent_at, :scheduled_at
      t.boolean :auto_tweet, :default => false
      t.string :posts
      t.editor_id :integer
      t.timestamps
    end

    add_index :refinery_mailchimp_weekly_campaigns, :id
  end

  def self.down
    if defined?(::Refinery::UserPlugin)
      ::Refinery::UserPlugin.destroy_all({:name => "refinerycms-mailchimp-weekly-campaign"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/weekly_campaigns"})
    end

    drop_table :refinery_mailchimp_weekly_campaigns
  end

end
