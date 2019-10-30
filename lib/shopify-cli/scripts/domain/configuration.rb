# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class Configuration
        attr_reader :id
        attr_reader :schema

        def initialize(id, schema)
          @id = id
          @schema = schema
        end
      end
    end
  end
end
