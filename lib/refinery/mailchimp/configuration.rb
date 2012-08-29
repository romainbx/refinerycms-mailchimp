module Refinery
  module Mailchimp
    include ActiveSupport::Configurable

    config_accessor :api_key, :weekly_campaign_id, :day_to_send_weekly_newsletter,
      :day_to_send_free_edito, :day_to_send_free_posts

    self.api_key = "Set me!"
    self.weekly_campaign_id = "Set me!"
    self.day_to_send_weekly_newsletter = -1
    self.day_to_send_free_edito = -1
    self.day_to_send_free_posts = -1

  end
end
