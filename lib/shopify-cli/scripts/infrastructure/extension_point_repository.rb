# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ExtensionPointRepository < Repository
        def initialize(script_service)
          @script_service = script_service
        end

        def get_extension_point(type, script_name)
          schema_path = schema_path(type, script_name)
          schema = if File.exist?(schema_path)
            File.read(schema_path)
          else
            fetch_extension_point(type, script_name)
          end
          Domain::ExtensionPoint.new(schema_path, type, schema)
        end

        private

        def schema_root(type, script_name)
          "#{SOURCE_PATH}/#{type}/#{script_name}/types"
        end

        def schema_path(type, script_name)
          "#{schema_root(type, script_name)}/#{type}.schema"
        end

        def fetch_extension_point(type, script_name)
          schema = @script_service
            .fetch_extension_points
            .select { |ep| ep["name"] == type }
            .each { |ep| create_extension_point(ep["name"], ep["schema"], script_name) }
            .map { |ep| ep["schema"] }
            .first

          raise Domain::InvalidExtensionPointError.new(type: type) unless schema
          schema
        end

        def create_extension_point(type, schema, script_name)
          # Sync schema file
          schema_root = schema_root(type, script_name)

          FileUtils.mkdir_p(schema_root)
          File.write(schema_path(type, script_name), schema)

          # Derive types from schema
          schema_types = GraphQLTypeScriptBuilder.new(schema).build
          File.write("#{schema_root}/#{type}.ts", schema_types)
        end
      end
    end
  end
end
