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
          write_npmrc
          write_package_json
          output, status = @ctx.capture2e("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
          raise Infrastructure::DependencyInstallError, output unless status.success?
        end

        private

        def write_npmrc
          npmrc = <<~HERE
            @shopify:registry=https://registry.npmjs.org/
          HERE

          File.write(".npmrc", npmrc)
        end

        def write_package_json
          package_json = <<~HERE
            {
              "name": "#{@script_name}",
              "version": "1.0.0",
              "devDependencies": {
                "@shopify/scripts-sdk-as": "^1.2.4",
                "@as-pect/assembly": "3.1.1",
                "@as-pect/cli": "3.1.1",
                "@as-pect/core": "3.1.1",
                "as-wasi": "^0.0.1",
                "assemblyscript": "0.9.4",
                "ts-node": "^8.5.4",
                "typescript": "^3.7.3"
              },
              "scripts": {
                "test": "asp --config test/as-pect.config.js --summary --verbose"
              }
            }
          HERE

          File.write("package.json", package_json)
        end
      end
    end
  end
end
