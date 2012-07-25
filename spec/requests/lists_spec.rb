require 'spec_helper'

describe "Lists" do
  describe "GET /lists" do
    refinery_login_with :refinery_user
    
    it "should have the same count lists as mailchimp" do 
      # visit refinery.mailchimp_admin_lists_path
      # lists = Gibbon.lists["data"]
      # page.should have_selector("ul#lists li", :count => lists.count)
    end

    it "should have the same count campaigns as mailchimp" do 
      # visit refinery.mailchimp_admin_lists_path
      # campaigns = Gibbon.campaigns["data"]
      # page.should have_selector("ul#campaigns li", :count => campaigns.count)
    end

  end
end
