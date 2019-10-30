# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class ExtensionPoint
        attr_reader :id
        attr_reader :type
        attr_reader :schema

        def initialize(id, type, schema)
          @id = id
          @type = type
          @schema = schema
        end

        def schema_file
          File.open(@id)
        end
      end
    end
  end
end
