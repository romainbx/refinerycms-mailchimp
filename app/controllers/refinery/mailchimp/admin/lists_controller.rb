module Refinery
  module Mailchimp
    module Admin
      class ListsController < ::Refinery::AdminController

        respond_to :html

        def index
          # @lists = Gibbon.lists['data']
        end

        def show
          # @members = Gibbon.list_members(:id => params['id'])['data']
        end

      end
    end
  end
end
