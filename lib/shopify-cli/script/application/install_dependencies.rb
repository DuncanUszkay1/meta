module ShopifyCli
  module ScriptModule
    module Application
      class InstallDependencies
        def self.call(ctx, language, script_name)
          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(ctx, script_name, language)
          dep_manager.install unless dep_manager.installed?
        end
      end
    end
  end
end
