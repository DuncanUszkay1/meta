# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ForbiddenError < StandardError
        def cause_of_error
          'You do not have permission to do this action.'
        end
      end
    end
  end
end
