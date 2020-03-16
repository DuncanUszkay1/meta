# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class AppNotInstalledError < StandardError
        def initialize
          super("The app is not installed on the shop.")
        end

        def cause_of_error
          "App not installed on development store."
        end

        def help_suggestion
          nil
        end
      end
    end
  end
end
