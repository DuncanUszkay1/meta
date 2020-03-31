# frozen_string_literal: true

BOOTSTRAP_TEST = "npx shopify-scripts-bootstrap test %{test_base}"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TestSuiteRepository < Repository
        TEST_TEMPLATE_NAME = "template"

        def create_test_suite(script)
          # Remove this once we have a test suite for js
          return unless script.language == "ts"

          FileUtils.mkdir_p(test_base)
          FileUtils.copy(aspect_config_template(script.language), "#{test_base}/as-pect.config.js")
          out, status = CLI::Kit::System.capture2e(format(BOOTSTRAP_TEST, test_base: test_base))
          raise Domain::ServiceFailureError, out unless status.success?
        end

        def get_test_suite(language, extension_point_type, script_name)
          ScriptRepository.new.get_script(language, extension_point_type, script_name)

          source = "#{test_base}/script.spec.#{language}"
          raise Domain::TestSuiteNotFoundError.new(extension_point_type, script_name) unless File.exist?(source)
        end

        def with_test_suite_context
          Dir.chdir(test_base) do
            yield
          end
        end

        private

        def test_base
          "#{ShopifyCli::ScriptModule::ScriptProject.current.directory}/test"
        end

        def aspect_config_template(language)
          "#{INSTALLATION_BASE_PATH}/templates/#{language}/as-pect.config.js"
        end
      end
    end
  end
end
