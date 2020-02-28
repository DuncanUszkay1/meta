# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class AppScriptUndefinedError < StandardError
        def initialize(api_key)
          super("No app script has been defined for app (#{api_key}).")
        end
      end
    end
  end
end
