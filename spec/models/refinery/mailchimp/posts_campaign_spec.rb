require 'spec_helper'

describe "Posts campaigns" do
  setup_mailchimp

  it "should be added successfully" do 
    posts_campaign = FactoryGirl.create(:posts_campaign)
    posts_campaign.new_record?.should be_false
  end

end
