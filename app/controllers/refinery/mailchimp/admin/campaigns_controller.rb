module Refinery
  module Mailchimp
    module Admin
      class CampaignsController < ::Refinery::AdminController
        respond_to :html
        helper Refinery::Mailchimp::CampaignHelper
        crudify :'refinery/mailchimp/campaign', :title_attribute => 'subject', :xhr_paging => true, :sortable => false

        rescue_from Refinery::Mailchimp::API::BadAPIKeyError, :with => :need_api_key
        rescue_from Hominid::APIError, :with => :need_api_key

        before_filter :get_mailchimp_assets, :except => :index
        before_filter :find_campaign, :except => [:index, :new, :create]
        before_filter :fully_qualify_links, :only => [:create, :update]
        skip_before_filter :get_mailchimp_assets, :if => lambda {|c| !!request.xhr? }

        def new
          @campaign = ::Refinery::Mailchimp::Campaign.new :from_name => ::Refinery::Setting.get_or_set(Refinery::Mailchimp::API::DefaultFromNameSetting[:name], Refinery::Mailchimp::API::DefaultFromNameSetting[:default]),
                                                          :from_email => ::Refinery::Setting.get_or_set(Refinery::Mailchimp::API::DefaultFromEmailSetting[:name], Refinery::Mailchimp::API::DefaultFromEmailSetting[:default])
        end
        
        def create
          @campaign = Campaign.create(params[:campaign])
          
          if @campaign.save
            flash[:notice] = t('refinery.crudify.created', :what => "'#{@campaign.subject}'")
            respond_with(@campaign, :status => :created, :location => refinery.mailchimp_admin_campaigns_path) 
          else
            respond_with(@campaign, :status => :unprocessable_entity) 
          end
        end

        def send_options
        end

        def send_test
          if @campaign.send_test_to params[:email]
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.send_test_success', :email => params[:email])
            logger.info "Great Successs !! \n \n \n \n"
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.send_test_failure', :email => params[:email])
            logger.info "Great Failure !! \n \n \n \n"

          end
          sending_redirect_to refinery.mailchimp_admin_campaigns_path
        end

        def send_now
          if @campaign.send_now
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.send_now_success')
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.send_now_failure')
          end
          sending_redirect_to refinery.mailchimp_admin_campaigns_path
        end

        def schedule
          schedule_date = DateTime.new(*params['date'].values_at('year','month','day','hour','minute').map{|x|x.to_i})
          if @campaign.schedule_for schedule_date
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.schedule_success')
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.schedule_failure')
          end
          sending_redirect_to refinery.mailchimp_admin_campaigns_path
        end

        def unschedule
          if @campaign.unschedule
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.unschedule_success')
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.unschedule_failure')
          end
          sending_redirect_to refinery.mailchimp_admin_campaigns_path
        end

        def posts
          render :text => "here is a test"
        end

      protected
        def sending_redirect_to(path)
          if from_dialog?
            render :text => "<script>parent.window.location = '#{path}';</script>"
          else
            redirect_to path
          end
        end

        def need_api_key
          msg = t('refinery.mailchimp.admin.campaigns.index.set_api_key')
          flash[:alert] = msg.html_safe
          redirect_to refinery.mailchimp_admin_campaigns_path
        end

        def fully_qualify_links
          #params[:campaign][:body].gsub!(/(href|src)="\//i, %|\\1="#{root_url}|)
        end

        def get_mailchimp_assets
          @lists = client.lists['data']
          @templates = client.templates['user']
        end

        def client
          @client ||= Refinery::Mailchimp::API.new
        end
      end
      end
  end
end
