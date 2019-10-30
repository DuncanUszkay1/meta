# frozen_string_literal: true

require "tmpdir"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptRepository < Repository
        def create_script(language, extension_point, script_name)
          # Source code template, default config
          dependencies(extension_point, script_name, language).each do |dep|
            FileUtils.cp_r(dep[:src], dep[:dest])
          end

          source = source(extension_point, script_name, language)
          configuration = create_configuration(extension_point, script_name)

          Domain::Script.new(source, script_name, extension_point, configuration, language)
        end

        def get_script(language, extension_point, name)
          source = source(extension_point, name, language)
          raise Domain::ScriptNotFoundError.new(name, extension_point) unless File.exist?(source)

          configuration = get_configuration(extension_point, name)

          Domain::Script.new(source, name, extension_point, configuration, language)
        end

        def load_script_source(language, extension_point, name)
          # Just validates that the script exists at all.
          get_script(language, extension_point, name)

          Dir.mktmpdir do |tmp|
            Dir.chdir(tmp) do
              FileUtils.cp_r("#{src_base(extension_point, name)}/.", ".")
              yield
            end
          end
        end

        private

        def create_configuration(extension_point, script_name)
          repo = ConfigurationRepository.new
          repo.create_configuration(extension_point, script_name)
        end

        def get_configuration(extension_point, script_name)
          repo = ConfigurationRepository.new
          repo.get_configuration(extension_point, script_name)
        end

        def source(extension_point, name, language)
          "#{src_base(extension_point, name)}/#{name}.#{language}"
        end

        def dependencies(extension_point, script_name, language)
          root = src_base(extension_point, script_name)
          [
            { src: code_template(extension_point, language), dest: "#{root}/#{script_name}.#{language}" },
            { src: runtime_types, dest: root },
          ]
        end

        def src_base(extension_point, script_name)
          "#{SOURCE_PATH}/#{extension_point.type}/#{script_name}"
        end

        def runtime_types
          "#{INSTALLATION_BASE_PATH}/schemas/shopify_runtime_types.ts"
        end

        def code_template(extension_point, language)
          "#{INSTALLATION_BASE_PATH}/templates/typescript/#{extension_point.type}.#{language}"
        end
      end
    end
  end
end
