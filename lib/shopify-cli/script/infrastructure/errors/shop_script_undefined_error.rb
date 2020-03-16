# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ShopScriptUndefinedError < StandardError
        def cause_of_error
          "Script is already turned off in development store."
        end

        def help_suggestion
          nil
        end
      end
    end
  end
end
