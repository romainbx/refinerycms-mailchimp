require 'spec_helper'

describe "Campaigns" do
  refinery_login_with :refinery_user
  setup_mailchimp

  it "should have the link to see all the posts campaigns" do
    visit refinery.mailchimp_admin_campaigns_path
    page.should have_selector("a#posts_campaigns")
  end

  def fill_in_posts_campaign_form
    fill_in "posts_campaign_from_name", :with => "mark"
    fill_in "posts_campaign_from_email", :with => "mark@secondbureau.com"
    fill_in "posts_campaign_subject", :with => "a subject"
    select("lizhe_2012", :from => "posts_campaign_mailchimp_list_id")
    click_button("submit_button")
  end

  it "should have the ability to add new posts campaigns" do
    post1 = create(:blog_post, {
      :title => "post 1"
    })
    post2 = create(:blog_post, {
      :title => "post 2"
    })
    visit refinery.mailchimp_admin_posts_campaigns_path
    page.should have_selector("a#add_new_posts_campaign")

    find("a#add_new_posts_campaign").click
    current_path.should == refinery.new_mailchimp_admin_posts_campaign_path
    
    within("form.new_posts_campaign") do
      check "post_#{post1.id}"
      check "post_#{post2.id}"
      fill_in_posts_campaign_form
    end

    Refinery::Mailchimp::PostsCampaign.count.should == 1
    post_campaign = Refinery::Mailchimp::PostsCampaign.first
    post_campaign.posts.should == ["#{post1.id}", "#{post2.id}"]
    post_campaign.body.should include(refinery.blog_post_url(post1), refinery.blog_post_url(post2))

    page.should have_selector("#records")
    page.should have_selector("#records ul li.record:first span.posts_campaign_title")
    page.should have_content("a subject")

    current_path.should == refinery.mailchimp_admin_posts_campaigns_path

    find("#records ul li.record:first span.actions a.edit_posts_campaign").click

    find("input[type=checkbox]#post_1").should be_checked
    find("input[type=checkbox]#post_2").should be_checked

  end

  it "should have a list of posts campaigns" do
    post1 = create(:blog_post, {
      :title => "post 1"
    })
    post2 = create(:blog_post, {
      :title => "post 2"
    })
    create_list(:posts_campaign, 5)
    pc = create(:posts_campaign, :subject => "my campaign subject")
    visit refinery.mailchimp_admin_posts_campaigns_path

    page.should have_selector("#records ul li.record", :count => 6)

    find("#records ul li.record:first span.actions a.delete_posts_campaign").click
    current_path.should == refinery.mailchimp_admin_posts_campaigns_path
    page.should have_selector("#records ul li.record", :count => 5)

    find("#records ul li.record:last span.actions a.edit_posts_campaign").click
    pc.posts.should == []
    page.should have_css("input[value='my campaign subject']")
    page.should have_selector("form.edit_posts_campaign")
    
    within("form.edit_posts_campaign") do
      check "post_#{post1.id}"
      check "post_#{post2.id}"
      fill_in_posts_campaign_form
    end

    current_path.should == refinery.mailchimp_admin_posts_campaigns_path

    pc.reload
    pc.posts.should == ["#{post1.id}", "#{post2.id}"]
    pc.body.should include(refinery.blog_post_url(post1), refinery.blog_post_url(post2))
  end


end
