require 'spec_helper'

describe "Campaigns" do
  refinery_login_with :refinery_user
  setup_mailchimp

  it "should have the ability to add new posts campaigns", :js => true do
    visit refinery.mailchimp_admin_posts_campaigns_path
    page.should have_selector("a#add_new_posts_campaign")

    click_link("add_new_posts_campaign")
    current_path.should == refinery.new_mailchimp_admin_posts_campaign_path
    
    within("#new_posts_campaign") do
      fill_in "posts_campaign_from_name", :with => "mark"
      fill_in "posts_campaign_from_email", :with => "mark@secondbureau.com"
      fill_in "posts_campaign_subject", :with => "a subject"
      select("lizhe_2012", :from => "posts_campaign_mailchimp_list_id")
      click_button("submit_button")

    end

    page.should_not have_selector("#errorExplanation")
    Refinery::Mailchimp::PostsCampaign.count.should == 1
  end

end
