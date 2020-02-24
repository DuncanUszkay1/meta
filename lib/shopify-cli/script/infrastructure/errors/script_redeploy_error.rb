# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptRedeployError < StandardError
        def initialize(api_key)
          super("A script with this extension point already exists on app (#{api_key}).")
        end
      end
    end
  end
end
