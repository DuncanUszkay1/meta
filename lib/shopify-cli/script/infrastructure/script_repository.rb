# frozen_string_literal: true

require "tmpdir"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptRepository < Repository
        def create_script(language, extension_point, script_name)
          source_file_path = src_code_file(language, script_name)

          FileUtils.mkdir_p(src_base)
          File.write(source_file_path, extension_point.example_scripts[language])

          write_sdk(
            extension_point.type,
            language,
            extension_point.sdk_types
          )

          Domain::Script.new(
            script_id(language, script_name),
            script_name,
            extension_point.type,
            language
          )
        end

        def get_script(language, extension_point_type, script_name)
          source_file_path = src_code_file(language, script_name)
          unless File.exist?(source_file_path)
            raise Domain::ScriptNotFoundError.new(extension_point_type, source_file_path)
          end

          Domain::Script.new(script_id(language, script_name), script_name, extension_point_type, language)
        end

        def with_temp_build_context
          prev_dir = Dir.pwd
          temp_dir = "#{project_base}/temp"
          FileUtils.mkdir_p(temp_dir)
          Dir.chdir(temp_dir)
          FileUtils.cp_r("#{src_base}/.", ".")
          yield

        ensure
          Dir.chdir(prev_dir)
          FileUtils.rm_rf(temp_dir)
        end

        private

        def write_sdk(extension_point_type, language, sdk_types)
          return unless language == "ts"

          File.write(sdk_types_file(extension_point_type, language), sdk_types)
        end

        def project_base
          ShopifyCli::ScriptModule::ScriptProject.current.directory
        end

        def src_base
          "#{project_base}/#{relative_path_to_src}"
        end

        def relative_path_to_src
          "src"
        end

        def script_id(language, script_name)
          "#{relative_path_to_src}/#{file_name(language, script_name)}"
        end

        def src_code_file(language, script_name)
          "#{src_base}/#{file_name(language, script_name)}"
        end

        def file_name(language, script_name)
          "#{script_name}.#{language}"
        end

        def sdk_types_file(extension_point_type, language)
          "#{src_base}/#{extension_point_type}.#{language}"
        end

        def file_path(script)
          src_code_file(script.language, script.name)
        end
      end
    end
  end
end
