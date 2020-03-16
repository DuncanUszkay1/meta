require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      require 'shopify-cli/commands/create/script'

      class ScriptTest < MiniTest::Test
        def setup
          super
          ENV.stubs(:[]).with('SCRIPTS_PLATFORM').returns('true')
          @cmd = ShopifyCli::Commands::Create::Script.new
          @cmd.ctx = @context
          @script_name = 'script_name'
          @ep_name = 'discount'
          @cmd.options = Class.new
          @cmd.options.stubs(:flags).returns({ ep_name: @ep_name, script_name: @script_name })
          @language = 'ts'
        end

        def test_invalid_ep_error_halts_execution
          @cmd.expects(:authenticate_partner_identity).with(@context)
          @cmd.expects(:install_dependencies).never

          @cmd.stubs(:bootstrap).raises(
            ScriptModule::Domain::InvalidExtensionPointError,
            type: 'type'
          )

          assert_raises(ShopifyCli::AbortSilent) do
            capture_io do
              @cmd.call([], 'create')
            end
          end
        end

        def test_can_create_new_script
          @cmd.expects(:authenticate_partner_identity).with(@context)
          @cmd.expects(:bootstrap).with(@context, @language, @ep_name, @script_name).returns(
            ShopifyCli::ScriptModule::Domain::Script.new(@script_name, @ep_name, @language)
          )
          ShopifyCli::ScriptModule::Presentation::DependencyInstaller
            .expects(:call).with(@context, @language, @script_name, @cmd.class::OPERATION_FAILED_MESSAGE)

          capture_io do
            @cmd.call([], 'create')
          end
        end

        def test_graphql_error_will_abort
          @cmd.stubs(:authenticate_partner_identity).with(@context).raises(
            ShopifyCli::ScriptModule::Infrastructure::GraphqlError.new('script-service', [])
          )
          assert_raises(ShopifyCli::AbortSilent) do
            capture_io do
              @cmd.call([], 'create')
            end
          end
        end
      end
    end
  end
end
