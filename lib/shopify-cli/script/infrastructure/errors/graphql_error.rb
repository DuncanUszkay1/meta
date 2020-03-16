# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class GraphqlError < StandardError
        attr_reader :errors
        def initialize(service_name, errors)
          @errors = errors
          super("GraphQL response from #{service_name} with errors: #{errors}")
        end
      end
    end
  end
end
