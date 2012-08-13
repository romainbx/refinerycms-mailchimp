module Refinery
  module Mailchimp
    module CampaignHelper
      def preview campaign
        if campaign.sent?
          content_tag_for(:span, campaign, :class => 'preview') do
            <<-PREVIEW
              #{t('sent', :scope => 'refinery.mailchimp.shared').downcase}  
              #{distance_of_time_in_words_to_now(campaign.sent)}  
              #{t('ago', :scope => 'refinery.mailchimp.shared')}
            PREVIEW
          end
        elsif campaign.scheduled?
          content_tag_for(:span, campaign, :class => 'preview') do
            <<-PREVIEW
              #{t('sending_in', :scope => 'refinery.mailchimp.shared').downcase}  
              #{distance_of_time_in_words_to_now(campaign.scheduled_at)}
            PREVIEW
          end
        else
          content_tag(:span, 'no content')
        end
      end
    end
  end
end
