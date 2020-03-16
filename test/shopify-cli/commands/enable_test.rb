require 'test_helper'

module ShopifyCli
  module Commands
    class EnableTest
      def setup
        super
        @ep_type = 'discount'
        project_stub = stub(extension_point_type: @ep_type)
        ShopifyCli::ScriptModule::ScriptProject.stubs(:current).returns(project_stub)

        @cmd = ShopifyCli::Commands::Enable
        @cmd.ctx = @context
        @cmd_name = 'enable'
      end

      def test_calls_application_enable
        api_key = 'key'
        shop_id = '1'
        @cmd.expects(:authenticate_partner_identity).with(@context)
        ShopifyCli::ScriptModule::Application::Enable.expects(:call).with(
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
        @cmd.stubs(:authenticate_partner_identity).with(@context).raises(
          ShopifyCli::ScriptModule::Infrastructure::GraphqlError
        )
        assert_raises(ShopifyCli::Abort) do
          capture_io do
            @cmd.call(['--api_key', api_key, '--shop_id', shop_id], @cmd_name)
          end
        end
      end
    end
  end
end
