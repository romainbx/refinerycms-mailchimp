FactoryGirl.define do
  
  factory :posts_campaign, :class => Refinery::Mailchimp::PostsCampaign do
    sequence(:from_name){|n| "from #{n} people" }
    sequence(:from_email){|n| "from.#{n}.email@secondbureau.com" }
    sequence(:subject){|n| "subject #{n}" }
    sequence(:body){|n| "body #{n}" }
    mailchimp_list_id "e553b4b9ae"
  end

end
