require 'test_helper'

module ShopifyCli
  module Commands
    class EnableTest < MiniTest::Test
      include TestHelpers::Errors
      include TestHelpers::Project

      def setup
        super
        @configuration = '{}'
        @ep_type = 'discount'
        @script_name = 'script'
        stub_script_project(extension_point_type: @ep_type, script_name: @script_name)

        @cmd = ShopifyCli::Commands::Enable
        @cmd.ctx = @context
        @cmd_name = 'enable'
      end

      def test_calls_application_enable
        api_key = 'key'
        shop_id = '1'
        @cmd.any_instance.expects(:authenticate_partner_identity).with(@context)
        ShopifyCli::ScriptModule::Application::Enable.expects(:call).with(
          @context,
          api_key,
          shop_id.to_i,
          @configuration,
          @ep_type,
          @script_name
        )
        capture_io do
          @cmd.call(['--api_key', api_key, '--shop_id', shop_id], @cmd_name)
        end
      end
    end
  end
end
