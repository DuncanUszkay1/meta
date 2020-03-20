require 'test_helper'

module ShopifyCli
  module Commands
    class DisableTest
      include TestHelpers::Errors

      def setup
        super
        @ep_type = 'discount'
        project_stub = stub(extension_point_type: @ep_type)
        ShopifyCli::ScriptModule::ScriptProject.stubs(:current).returns(project_stub)

        @cmd = ShopifyCli::Commands::Disable
        @cmd.ctx = @context
        @cmd_name = 'disable'
      end

      def test_calls_application_disable
        api_key = 'key'
        shop_id = '1'
        @cmd.expects(:authenticate_partner_identity).with(@context)
        ShopifyCli::ScriptModule::Application::Disable.expects(:call).with(
          @context,
          api_key,
          shop_id,
          @ep_type
        )
        capture_io do
          @cmd.call(['--api_key', api_key, '--shop_id', shop_id], @cmd_name)
        end
      end

      def test_graphql_error_will_abort
        assert_silent_abort_when_raised(
          @cmd.stubs(:authenticate_partner_identity),
          ShopifyCli::ScriptModule::Infrastructure::GraphqlError.new('script-service', [])
        ) do
          @cmd.call(['--api_key', api_key, '--shop_id', shop_id], @cmd_name)
        end
      end
    end
  end
end
