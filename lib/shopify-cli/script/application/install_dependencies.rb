module ShopifyCli
  module ScriptModule
    module Application
      class InstallDependencies
        def self.call(ctx, language, script_name)
          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(ctx, script_name, language)
          unless dep_manager.installed?
            dep_manager.install
          end
        end
      end
    end
  end
end
