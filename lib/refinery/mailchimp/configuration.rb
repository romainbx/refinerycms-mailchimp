module Refinery
  module Mailchimp
    include ActiveSupport::Configurable

    config_accessor :api_key, :weekly_campaign_id

    self.api_key = "Set me!"
    self.weekly_campaign_id = "Set me!"

  end
end

