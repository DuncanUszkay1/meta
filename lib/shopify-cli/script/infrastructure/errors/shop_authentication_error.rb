# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ShopAuthenticationError < StandardError
        def initialize
          super("Unable to authenticate partner with the shop.")
        end

        def cause_of_error
          "Unable to authenticate with the store."
        end
      end
    end
  end
end
