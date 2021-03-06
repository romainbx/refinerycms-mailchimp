module Refinery
  module Mailchimp
    module Admin
      class PostsCampaignsController < ::Refinery::AdminController
        include ActionView::Helpers::TextHelper
        helper Refinery::Mailchimp::PostsCampaignHelper
        respond_to :html
        crudify :'refinery/mailchimp/posts_campaign', :title_attribute => 'subject',
          :xhr_paging => true, :sortable => false

        rescue_from Refinery::Mailchimp::API::BadAPIKeyError, :with => :need_api_key
        rescue_from Hominid::APIError, :with => :need_api_key

        before_filter :get_mailchimp_assets, :except => :index
        before_filter :find_posts_campaign, :except => [:index, :new, :create, :pause, :resume]
        before_filter :fully_qualify_links, :only => [:create, :update]
        before_filter :set_campaign_body, :only => [:create, :update]
        before_filter :find_posts, :only => [:new, :edit, :create]
        skip_before_filter :get_mailchimp_assets, :if => lambda {|c| !!request.xhr? }

        def index
          if params[:nltype]
            @posts_campaigns = Refinery::Mailchimp::PostsCampaign.where(:nltype => "#{params[:nltype]}").paginate(:page => params[:page])
          else
            @posts_campaigns = Refinery::Mailchimp::PostsCampaign.paginate(:page => params[:page])
          end
        end

        def new
          name = Refinery::Mailchimp::API::DefaultFromNameSetting[:name]
          default_name = Refinery::Mailchimp::API::DefaultFromNameSetting[:default]
          email = Refinery::Mailchimp::API::DefaultFromEmailSetting[:name]
          default_email = Refinery::Mailchimp::API::DefaultFromEmailSetting[:default]
          from_name = ::Refinery::Setting.get_or_set(name, default_name)
          from_email =::Refinery::Setting.get_or_set(email, default_email)
          @posts_campaign = ::Refinery::Mailchimp::PostsCampaign.new :from_name => from_name, :from_email => from_email
          @posts_campaign.nltype = params[:nltype]
          respond_to do |format|
            format.js { render :edit, :layout => false }
            format.html
          end
        end

        def edit
          respond_to do |format|
            format.js {render :layout => false}
            format.html
          end
        end

        def create
          params[:posts_campaign][:posts] = [] if params[:posts_campaign][:posts] == ""
          @posts_campaign = PostsCampaign.create(params[:posts_campaign])
          if @posts_campaign.save
            flash[:notice] = t('refinery.crudify.created', :what => "'#{@posts_campaign.subject}'")
            location = refinery.mailchimp_admin_posts_campaigns_path
            respond_with(@posts_campaign, 
                         :status => :created,
                         :location => location)
          else
            respond_with @posts_campaign, :status => :unprocessable_entity
          end
        end

        def update
          PostsCampaign.find(params[:id]).update_attributes(params[:posts_campaign])
          redirect_to refinery.mailchimp_admin_posts_campaigns_path
        end

        def pause
          setting_key = "#{Refinery::Mailchimp::PostsCampaign.string_nltype(params[:nltype].to_i)}_pause"
          setting = Refinery::Setting.set(setting_key, true)
          flash[:notice] = t('refinery.mailchimp.admin.campaigns.shared.paused')
          redirect_to :back
        end

        def resume
          setting_key = "#{Refinery::Mailchimp::PostsCampaign.string_nltype(params[:nltype].to_i)}_pause"
          setting = Refinery::Setting.set(setting_key, false)
          flash[:notice] = t('refinery.mailchimp.admin.campaigns.shared.resumed')
          redirect_to :back
        end

        def send_options
        end

        def send_test
          if @posts_campaign.send_test_to params[:email]
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.send_test_success', :email => params[:email])
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.send_test_failure', :email => params[:email])
          end
          sending_redirect_to refinery.mailchimp_admin_posts_campaigns_path
        end

        def send_now
          if @posts_campaign.send_now
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.send_now_success')
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.send_now_failure')
          end
          sending_redirect_to refinery.mailchimp_admin_campaigns_path
        end

        def schedule
          schedule_date = DateTime.new(*params['date'].values_at('year','month','day','hour','minute').map{|x|x.to_i})
          if @posts_campaign.schedule_for schedule_date
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.schedule_success')
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.schedule_failure')
          end
          sending_redirect_to refinery.mailchimp_admin_posts_campaigns_path
        end

        def unschedule
          if @posts_campaign.unschedule
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.unschedule_success')
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.unschedule_failure')
          end
          sending_redirect_to refinery.mailchimp_admin_posts_campaigns_path
        end

        def add_post
          if @posts_campaign.posts.include? params[:post_id]
            @posts_campaign.posts.delete params[:post_id]
          else
            @posts_campaign.posts << params[:post_id]
          end
          @posts_campaign.save
          render :nothing => true
        end

      protected

        def set_campaign_body
          if params[:posts_campaign][:nltype] == "1"
            edition = Refinery::Blog::Edition.find params[:posts_campaign][:edito_id]
            @posts = edition.content_posts
            @edito = edition.edito
            @categories_posts = @posts.to_a.group_by{|post| post.categories.first.title }
            body_html = render_to_string(:partial => "weekly_newsletter")
          elsif params[:posts_campaign][:nltype] == "2"
            @edito = Refinery::Blog::Post.find params[:posts_campaign][:edito_id]
            body_html = render_to_string(:partial => "free_edito_newsletter")
          elsif params[:posts_campaign][:nltype] == "3"
            posts_ids = params[:posts_campaign][:posts].split(",")
            @posts = Refinery::Blog::Post.where(:id => posts_ids)
            params[:posts_campaign][:posts] = posts_ids
            @categories_posts = @posts.to_a.group_by{|post| post.categories.first.title }
            body_html = render_to_string(:partial => "free_posts_newsletter")
          end
          params[:posts_campaign][:body] = body_html
        end

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
          redirect_to refinery.mailchimp_admin_posts_campaigns_path
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

        def find_posts
          @posts = Refinery::Blog::Post.paginate(:page => params[:page])
        end

      end
    end
  end
end
