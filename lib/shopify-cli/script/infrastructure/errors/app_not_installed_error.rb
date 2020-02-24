# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class AppNotInstalledError < StandardError
        def initialize
          super("The app is not installed on the shop.")
        end
      end
    end
  end
end
