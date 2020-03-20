# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptRedeployError < StandardError
        attr_reader :api_key

        def initialize(api_key)
          @api_key = api_key
          super("Script with the same extension point already exists on app (API key:#{@api_key}).")
        end
      end
    end
  end
end
