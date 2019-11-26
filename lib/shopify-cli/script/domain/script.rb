# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class Script
        attr_reader :name, :extension_point, :language, :schema

        def initialize(name, extension_point, language, schema)
          @name = name
          @extension_point = extension_point
          @language = language
          @schema = schema
        end

        def id
          "#{extension_point.type}/#{filename}"
        end

        def filename
          "#{name}.#{language}"
        end
      end
    end
  end
end
