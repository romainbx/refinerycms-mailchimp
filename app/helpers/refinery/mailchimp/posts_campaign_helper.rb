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

      def action_link_new
        link = refinery.new_mailchimp_admin_posts_campaign_path
         if params[:with_edito]
           link = refinery.new_mailchimp_admin_posts_campaign_path(:with_edito => true)
         end
        link_to t('.create_new'), link, :id => "add_new_posts_campaign", :class => "add_icon"
      end

      def action_link_edit posts_campaign
        link = refinery.edit_mailchimp_admin_posts_campaign_path(posts_campaign)
        if params[:with_edito]
          link = refinery.edit_mailchimp_admin_posts_campaign_path(posts_campaign, :with_edito => true)
        end
        link_to refinery_icon_tag("application_edit.png"), link, :class => "edit_posts_campaign"
      end

      def action_link_send_email posts_campaign
        dialog_params = {:dialog => true, :width => 725, :height => 525}
        link_to refinery_icon_tag("email_go.png"),
          refinery.send_options_mailchimp_admin_posts_campaign_path(posts_campaign, dialog_params),
          :title => t('send_dialog', :scope => '.campaign')
      end

      def action_link_delete posts_campaign
        link_to refinery_icon_tag("delete.png"),
          refinery.mailchimp_admin_posts_campaign_path(posts_campaign),
          :method => :delete,
          :class => "delete_posts_campaign",
          :'data-confirm' => t('.delete_confirmation', :subject => posts_campaign.subject)
      end

      def render_posts_campaign_list posts_campaigns
        render :partial => 'posts_campaign', :collection => posts_campaigns
      end

      def searchable?
        ::Refinery::Mailchimp::Admin::CampaignsController.searchable?
      end

      def render_search_form
        content_tag(:li) do
          render :partial => "/refinery/admin/search",
            :locals => {:url => refinery.mailchimp_admin_posts_campaigns_url}
        end
      end

    end
  end
end
