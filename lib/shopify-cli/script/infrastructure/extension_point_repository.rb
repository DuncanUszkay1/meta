# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ExtensionPointRepository < Repository
        def get_extension_point(type)
          ScriptModule::Domain::ExtensionPoint.new(type, fetch_extension_point(type))
        end

        private

        def fetch_extension_point(type)
          extension_points = load_extension_points_yaml
          raise Domain::InvalidExtensionPointError.new(type: type) unless extension_points[type]
          extension_points[type]
        end

        def load_extension_points_yaml
          require 'yaml'
          YAML.load_file(File.join(ShopifyCli::ROOT, 'config/extension_points.yml'))
        end
      end
    end
  end
end
