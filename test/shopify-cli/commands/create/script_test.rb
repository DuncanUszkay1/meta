require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      require 'shopify-cli/commands/create/script'

      class ScriptTest < MiniTest::Test
        include TestHelpers::Errors

        def setup
          super
          ENV.stubs(:[]).with('SCRIPTS_PLATFORM').returns('true')
          @cmd = ShopifyCli::Commands::Create::Script.new
          @cmd.ctx = @context
          @script_name = 'script_name'
          @ep_name = 'discount'
          @ep = ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new
            .get_extension_point(@ep_name)
          @cmd.options = Class.new
          @cmd.options.stubs(:flags).returns({ ep_name: @ep_name })
          @language = 'ts'
        end

        def test_invalid_ep_error_halts_execution
          @cmd.expects(:authenticate_partner_identity).with(@context)
          @cmd.expects(:install_dependencies).never

          ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.any_instance
            .expects(:get_extension_point)
            .with(@ep_name)
            .returns(@ep)

          ShopifyCli::ScriptModule::ScriptProject.expects(:create).with(@script_name)

          ShopifyCli::ScriptModule::Application::ProjectDependencies
            .expects(:bootstrap).with(@context, @language, @ep, @script_name)

          ShopifyCli::ScriptModule::Presentation::DependencyInstaller
            .expects(:call).with(@context, @language, @ep, @script_name, @cmd.class::OPERATION_FAILED_MESSAGE)

          @cmd.stubs(:bootstrap).raises(
            ScriptModule::Domain::InvalidExtensionPointError,
            type: 'type'
          )

          assert_raises(ShopifyCli::AbortSilent) do
            capture_io { call_create }
          end
        end

        def test_can_create_new_script
          @cmd.expects(:authenticate_partner_identity) # .with(@context)

          ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.any_instance
            .expects(:get_extension_point)
            .with(@ep_name)
            .returns(@ep)

          ShopifyCli::ScriptModule::ScriptProject.expects(:create).with(@script_name)

          ShopifyCli::ScriptModule::Application::ProjectDependencies
            .expects(:bootstrap).with(@context, @language, @ep, @script_name)

          ShopifyCli::ScriptModule::Presentation::DependencyInstaller
            .expects(:call).with(@context, @language, @ep, @script_name, @cmd.class::OPERATION_FAILED_MESSAGE)

          @cmd.expects(:bootstrap).with(@context, @language, @ep, @script_name)
            .returns(
              ShopifyCli::ScriptModule::Domain::Script.new('id', @script_name, @ep_name, @language)
            )

          capture_io { call_create }
        end

        def test_graphql_error_will_abort
          assert_silent_abort_when_raised(
            @cmd.stubs(:authenticate_partner_identity),
            ShopifyCli::ScriptModule::Infrastructure::GraphqlError.new('script-service', [])
          ) do
            call_create
          end
        end

        private

        def call_create
          @cmd.call([@script_name], 'create')
        end
      end
    end
  end
end
