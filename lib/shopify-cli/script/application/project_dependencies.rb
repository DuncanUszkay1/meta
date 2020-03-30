module ShopifyCli
  module ScriptModule
    module Application
      class ProjectDependencies
        def self.bootstrap(ctx, language, script_name)
          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(ctx, script_name, language)
          dep_manager.bootstrap
        end

        def self.install(ctx, language, script_name)
          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(ctx, script_name, language)
          dep_manager.install
        end

        def self.installed?(ctx, language, script_name)
          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(ctx, script_name, language)
          dep_manager.installed?
        end

        def self.error_messages(failed_op_message = nil)
          {
            failed_op: failed_op_message,
            cause_of_error: "Something went wrong while installing the dependencies that are needed.",
            help_suggestion: "See https://help.shopify.com/en/",
          }
        end
      end
    end
  end
end
