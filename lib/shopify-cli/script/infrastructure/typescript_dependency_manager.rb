# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeScriptDependencyManager
        def initialize(ctx, script_name, language)
          @ctx = ctx
          @language = language
          @script_name = script_name
        end

        def installed?
          # Assuming if node_modules folder exist at root of script folder, all deps are installed
          Dir.exist?("node_modules")
        end

        def install
          write_package_json
          output, status = @ctx.capture2e("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
          raise Infrastructure::DependencyInstallError, output unless status.success?
        end

        private

        def write_package_json
          package_json = <<~HERE
            {
              "name": "#{@script_name}",
              "version": "1.0.0",
              "dependencies": {
                "@shopify/scripts-sdk": "file:./src/sdk/as"
              },
              "devDependencies": {
                "@as-pect/assembly": "3.0.0-beta.2",
                "@as-pect/cli": "3.0.0-beta.2",
                "@as-pect/core": "3.0.0-beta.2",
                "as-wasi": "^0.0.1",
                "assemblyscript": "0.9.2",
                "ts-node": "^8.5.4",
                "typescript": "^3.7.3"
              },
              "scripts": {
                "test": "asp --config test/as-pect.config.js"
              }
            }
          HERE

          File.write("package.json", package_json)
        end
      end
    end
  end
end
