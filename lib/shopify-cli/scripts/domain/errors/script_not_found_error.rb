# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class ScriptNotFoundError < StandardError
        def initialize(name, extension_point)
          super("script: #{name} for extension point: #{extension_point.type} not found")
        end
      end
    end
  end
end
