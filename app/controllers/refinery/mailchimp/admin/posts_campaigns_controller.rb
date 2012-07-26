module Refinery
  module Mailchimp
    module Admin
      class PostsCampaignsController < ::Refinery::AdminController
        respond_to :html
        crudify :'refinery/mailchimp/posts_campaign', :title_attribute => 'subject', :xhr_paging => true, :sortable => false

        rescue_from Refinery::Mailchimp::API::BadAPIKeyError, :with => :need_api_key
        rescue_from Hominid::APIError, :with => :need_api_key

        before_filter :get_mailchimp_assets, :except => :index
        before_filter :find_posts_campaign, :except => [:index, :new, :create]
        before_filter :fully_qualify_links, :only => [:create, :update]
        before_filter :set_campaign_body, :only => [:create, :update]
        before_filter :find_posts, :only => [:new, :edit]

        def new
          name = Refinery::Mailchimp::API::DefaultFromNameSetting[:name]
          default_name = Refinery::Mailchimp::API::DefaultFromNameSetting[:default]
          email = Refinery::Mailchimp::API::DefaultFromEmailSetting[:name]
          default_email = Refinery::Mailchimp::API::DefaultFromEmailSetting[:default]
          from_name = ::Refinery::Setting.get_or_set(name, default_name)
          from_email =::Refinery::Setting.get_or_set(email, default_email)
          @posts_campaign = ::Refinery::Mailchimp::PostsCampaign.new :from_name => from_name, :from_email => from_email
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
          @posts_campaign = PostsCampaign.create(params[:posts_campaign])
          if @posts_campaign.save
            flash[:notice] = t('refinery.crudify.created', :what => "'#{@posts_campaign.subject}'")
            respond_with(@posts_campaign, :status => :created, :location => refinery.mailchimp_admin_posts_campaigns_path) 
          else
            respond_with(@posts_campaign, :status => :unprocessable_entity) 
          end
        end

        def send_options
        end

        def send_test
          if @posts_campaign.send_test_to params[:email]
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.send_test_success', :email => params[:email])
            logger.info "Great Successs !! \n \n \n \n"
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.send_test_failure', :email => params[:email])
            logger.info "Great Failure !! \n \n \n \n"

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
          if @posts_campaign.schedule_for DateTime.new(*params['date'].values_at('year','month','day','hour','minute').map{|x|x.to_i})
            flash[:notice] = t('refinery.mailchimp.admin.campaigns.campaign.schedule_success')
          else
            flash[:alert] = t('refinery.mailchimp.admin.campaigns.campaign.schedule_failure')
          end
          sending_redirect_to mailchimp_admin_posts_campaigns_path
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
          if params[:posts_campaign][:posts].size > 0
            params[:posts_campaign][:posts] = params[:posts_campaign][:posts].split(",") 
          else
            params[:posts_campaign][:posts] = []
          end
          if params[:posts_campaign][:posts].any?
            params[:posts_campaign][:body] = "<ul id='blog_posts'>"
            real_posts = Refinery::Blog::Post.where(:id => params[:posts_campaign][:posts])
            real_posts.each do |post|
              params[:posts_campaign][:body] += "<li><h3><a href='#{refinery.blog_post_url(post)}'>#{post.title}</a></h3></li>"
            end
            params[:posts_campaign][:body] += "</ul>"
          else
            params[:posts_campaign][:body] = "there is no any content"
          end
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
