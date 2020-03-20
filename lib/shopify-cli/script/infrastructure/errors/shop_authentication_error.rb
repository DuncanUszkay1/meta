# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ShopAuthenticationError < StandardError
        def initialize
          super("Unable to authenticate partner with the shop.")
        end
      end
    end
  end
end
