require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class Script < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Create a new script for an extension point from the default template"
        CMD_USAGE = "create script --extension_point=<ep_name> --name=<script_name>"
        CREATED_NEW_SCRIPT_MSG = "{{v}} Your script is created: %{folder}/{{green:%{script_filename}}}"
        INVALID_EXTENSION_POINT = "Invalid extension point %{extension_point}"

        options do |parser, flags|
          parser.on('--extension_point=EP_NAME') { |ep_name| flags[:ep_name] = ep_name }
          parser.on('--name=SCRIPT_NAME') { |script_name| flags[:script_name] = script_name }
        end

        def call(_args, _name)
          unless options.flags.key?(:ep_name) && options.flags.key?(:script_name)
            self.class.call_help("create")
            return
          end

          language = 'ts'
          script_name = options.flags[:script_name]
          ep_name = options.flags[:ep_name]
          return @ctx.puts(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

          script = bootstrap(@ctx, language, ep_name, script_name)
          install_dependencies(@ctx, language, script_name)

          @ctx.puts(format(CREATED_NEW_SCRIPT_MSG, script_filename: script.filename, folder: script.name))
        rescue ScriptModule::Domain::InvalidExtensionPointError
          @ctx.puts(format(INVALID_EXTENSION_POINT, extension_point: extension_point))
        rescue StandardError => e
          raise(ShopifyCli::Abort, e)
        end

        def self.help
          <<~HELP
            #{CMD_DESCRIPTION}
              Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}
          HELP
        end

        private

        def install_dependencies(ctx, language, script_name)
          # dep_manager = ScriptModule::Infrastructure::DependencyManager.for(@ctx, script_name, language)
          CLI::UI::Frame.open("Installing dependencies with npm") do
            ScriptModule::Application::InstallDependencies.call(ctx, language, script_name)
          end
          @ctx.puts("{{v}} Dependencies installed")
        end

        def bootstrap(ctx, language, extension_point, name)
          CLI::UI::Frame.open("Cloning into #{name}") do
            CLI::UI::Progress.progress do |bar|
              script = ScriptModule::Application::Bootstrap.call(ctx, language, extension_point, name)
              bar.tick(set_percent: 1.0)
              script
            end
          end
        end
      end
    end
  end
end
