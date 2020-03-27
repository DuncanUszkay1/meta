require 'test_helper'

module ShopifyCli
  module Commands
    class DisableTest < MiniTest::Test
      include TestHelpers::Errors
      include TestHelpers::Project

      def setup
        super
        @ep_type = 'discount'
        stub_script_project(extension_point_type: @ep_type)

        @cmd = ShopifyCli::Commands::Disable
        @cmd.ctx = @context
        @cmd_name = 'disable'
      end

      def test_calls_application_disable
        api_key = 'key'
        shop_id = '1'
        @cmd.any_instance.expects(:authenticate_partner_identity).with(@context)
        ShopifyCli::ScriptModule::Application::Disable.expects(:call).with(
          @context,
          api_key,
          shop_id.to_i,
          @ep_type
        )
        capture_io do
          @cmd.call(['--api_key', api_key, '--shop_id', shop_id], @cmd_name)
        end
      end
    end
  end
end
