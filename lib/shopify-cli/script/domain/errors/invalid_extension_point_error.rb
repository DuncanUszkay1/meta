# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class InvalidExtensionPointError < StandardError
        def initialize(type:)
          super("Extension point #{type} can't be found")
        end
      end
    end
  end
end
