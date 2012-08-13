module Refinery
  module Mailchimp
    module CampaignHelper

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
        else
          content_tag(:span, 'no content')
        end
      end

      def action_link_edit campaign
        link_to refinery_icon_tag("application_edit.png"),
          refinery.edit_mailchimp_admin_campaign_path(campaign),
          :subject => t('.edit')
      end

      def action_link_send_email campaign
        link_to refinery_icon_tag("email_go.png"),
          refinery.send_options_mailchimp_admin_campaign_path(campaign, :dialog => true, :width => 725, :height => 525),
          :title => t('send_dialog', :scope => 'refinery.mailchimp.admin.campaigns.campaign')
      end

      def action_link_delete campaign
        link_to refinery_icon_tag("delete.png"),
          refinery.mailchimp_admin_campaign_path(campaign),
          :class => "cancel confirm-delete",
          :subject => t('.delete'),
          :'data-confirm' => t('refinery.mailchimp.admin.campaigns.campaign.delete_confirmation', :subject => campaign.subject),
          :'data-method' => :delete
      end

    end
  end
end
