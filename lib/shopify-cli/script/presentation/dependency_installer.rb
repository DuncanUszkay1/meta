module ShopifyCli
  module ScriptModule
    module Presentation
      class DependencyInstaller
        def self.call(ctx, language, extension_point, script_name, failed_op_message)
          unless ScriptModule::Application::ProjectDependencies.installed?(ctx, language, extension_point,script_name)
            success = CLI::UI::Frame.open("Installing dependencies with npm") do
              begin
                ShopifyCli::UI::StrictSpinner.spin('Dependencies installing') do |spinner|
                  ScriptModule::Application::ProjectDependencies.install(ctx, language, extension_point, script_name)
                  spinner.update_title('dependencies installed')
                end
                true
              rescue ScriptModule::Infrastructure::DependencyInstallError => e
                CLI::UI::Frame.with_frame_color_override(:red) do
                  ctx.puts("\n#{e.message}")
                end
                false
              end
            end

            return ShopifyCli::UI::ErrorHandler.display_and_raise(
              ScriptModule::Application::ProjectDependencies.error_messages(failed_op_message)
            ) unless success
          end
        end
      end
    end
  end
end
