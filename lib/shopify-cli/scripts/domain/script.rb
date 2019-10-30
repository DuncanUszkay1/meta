# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class Script
        attr_reader :id
        attr_reader :name
        attr_reader :extension_point
        attr_reader :configuration
        attr_reader :language

        def initialize(id, name, extension_point, configuration, language)
          @id = id
          @name = name
          @extension_point = extension_point
          @configuration = configuration
          @language = language
        end
      end
    end
  end
end
