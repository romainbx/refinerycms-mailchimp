module Refinery
  module Mailchimp
    module PostsCampaignHelper

      def preview campaign
        if campaign.sent?
          content_tag(:span, :class => 'preview') do
            <<-PREVIEW
              #{t('sent', :scope => 'refinery.mailchimp.shared').downcase}  
              #{distance_of_time_in_words_to_now(campaign.sent)}  
              #{t('ago', :scope => 'refinery.mailchimp.shared')}
            PREVIEW
          end
        elsif campaign.scheduled?
          content_tag(:span, :class => 'preview') do
            <<-PREVIEW
              #{t('sending_in', :scope => 'refinery.mailchimp.shared').downcase}  
              #{distance_of_time_in_words_to_now(campaign.scheduled_at)}
            PREVIEW
          end
        end
      end

      def action_link_edit posts_campaign
        link_to refinery_icon_tag("application_edit.png"),
          refinery.edit_mailchimp_admin_posts_campaign_path(posts_campaign),
          :class => "edit_posts_campaign"
      end

      def action_link_send_email posts_campaign
        link_to refinery_icon_tag("email_go.png"),
          refinery.send_options_mailchimp_admin_posts_campaign_path(posts_campaign, :dialog => true, :width => 725, :height => 525),
          :title => t('send_dialog', :scope => 'refinery.mailchimp.admin.campaigns.campaign')
      end

      def action_link_delete posts_campaign
        link_to refinery_icon_tag("delete.png"),
          refinery.mailchimp_admin_posts_campaign_path(posts_campaign),
          :method => :delete,
          :class => "delete_posts_campaign",
          :'data-confirm' => t('refinery.mailchimp.admin.campaigns.posts_campaign.delete_confirmation', :subject => posts_campaign.subject)
      end

      def searchable?
        ::Refinery::Mailchimp::Admin::CampaignsController.searchable?
      end

      def render_search_form
        content_tag(:li) do
          render :partial => "/refinery/admin/search", :locals => {:url => refinery.mailchimp_admin_posts_campaigns_url}
        end
      end

    end
  end
end
