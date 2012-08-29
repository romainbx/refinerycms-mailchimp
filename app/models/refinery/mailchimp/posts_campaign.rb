module Refinery
  module Mailchimp
    class PostsCampaign < Refinery::Core::BaseModel
      include Refinery::Core::Engine.routes.url_helpers

      WEEKLY, FREE_POSTS, FREE_EDITO = 1, 2, 3

      self.table_name = 'refinery_mailchimp_posts_campaigns'

      serialize :posts, Array

      attr_accessible :from_name, :from_email, :subject, :body, :mailchimp_list_id, :mailchimp_template_id, 
        :auto_tweet, :posts, :latest, :edito_id, :paused, :nltype

      scope :weekly, lambda{ where(:nltype => self::WEEKLY) }
      scope :free_posts, lambda{ where(:nltype => self::FREE_POSTS) }
      scope :free_edito, lambda{ where(:nltype => self::FREE_EDITO) }

      validates_presence_of :subject, :mailchimp_list_id, :from_email, :from_name

      before_save :update_mailchimp_campaign
      before_create :create_mailchimp_campaign
      before_destroy :delete_mailchimp_campaign

      def self.send_newsletter type
        last_campaign = Refinery::Mailchimp::PostsCampaign.send(type)
        setting = Refinery::Setting.find("#{post_campaign.string_nltype}_pause")
        last_campaign.send_now unless setting.value
      end

      def self.last_edition
        self.weekly.last
      end

      def self.last_free_posts
        self.free_posts.last
      end

      def self.last_free_edito
        self.free_edito.last
      end

      def string_nltype
        Refinery::Mailchimp::PostsCampaign.string_nltype self.nltype
      end

      def self.string_nltype nu
        case nu
        when 1 then "weekly"
        when 2 then "free_edito"
        when 3 then "free_posts"
        end
      end

      def edito
        @edito ||= Refinery::Blog::Category.find(self.edito_id)
      end

      def sent?
        !!sent_at || !!scheduled_at && scheduled_at <= Time.now
      end

      def scheduled?
        !!scheduled_at && scheduled_at > Time.now
      end

      def sent
        sent_at || scheduled_at
      end

      def send_test_to(*emails)
        Refinery::Mailchimp::API.new.campaign_send_test mailchimp_campaign_id, emails
      rescue Hominid::APIError
        false
      end

      def send_now
        success = Refinery::Mailchimp::API.new.campaign_send_now mailchimp_campaign_id
        self.update_attribute :sent_at, Time.now if success
        success
      rescue Hominid::APIError
        false
      end

      def schedule_for(datetime)
        success = Refinery::Mailchimp::API.new.campaign_schedule mailchimp_campaign_id, datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
        self.update_attribute :scheduled_at, datetime if success
        success
      rescue Hominid::APIError
        false
      end

      def unschedule
        success = Refinery::Mailchimp::API.new.campaign_unschedule mailchimp_campaign_id
        self.update_attribute :scheduled_at, nil if success
        success
      rescue Hominid::APIError
        false
      end

      def google_analytics
        RefinerySetting.find_or_set Refinery::Mailchimp::API::GoogleAnalyticsSetting[:name], Refinery::Mailchimp::API::GoogleAnalyticsSetting[:default]
      end

    protected

      def create_mailchimp_campaign
        options = { :subject => subject, :from_email => from_email, :from_name => from_name, :list_id => mailchimp_list_id, :auto_tweet => auto_tweet }
        options[:template_id] = mailchimp_template_id unless mailchimp_template_id.blank?
        
        self.mailchimp_campaign_id = begin
          Refinery::Mailchimp::API.new.campaign_create 'regular', options, { content_key => body }
        rescue Hominid::APIError => e
          halt_with_mailchimp_error e
          return false
        end
      end

      def update_mailchimp_campaign
        return if new_record?

        client = Refinery::Mailchimp::API.new

        options = {:title => :subject, :from_email => :from_email, :from_name => :from_name, :list_id => :mailchimp_list_id, :template_id => :mailchimp_template_id, :content => :body, :auto_tweet => :auto_tweet }
        options.each_pair do |option_name, attribute|
          if changed.include?(attribute.to_s)
            begin 
              success = client.campaign_update mailchimp_campaign_id, option_name, (option_name == :content ? { content_key => body } : self.send(attribute))
            rescue Hominid::APIError => e
              return halt_with_mailchimp_error e
            end
          end
        end
      end

      def delete_mailchimp_campaign
        success = begin
          Refinery::Mailchimp::API.new.campaign_delete mailchimp_campaign_id
        rescue Hominid::APIError
          nil
        end

        return halt_with_mailchimp_error unless success
      end

      def halt_with_mailchimp_error error
        self.errors.add :base, error.message
        return false
      end

      def content_key
        mailchimp_template_id.blank? ? :html : :html_MAIN
      end
    end
  end
end

