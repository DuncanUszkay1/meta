# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class AuthenticatePartnerIdentity
        def self.call(ctx)
          Infrastructure::PartnerDashboard.new(ctx: ctx).authenticate
        end
      end
    end
  end
end
