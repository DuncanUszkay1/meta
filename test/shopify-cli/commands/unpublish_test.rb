require 'test_helper'

module ShopifyCli
  module Commands
    class UnpublishTest
      def setup
        super
        @ep_type = 'discount'
        project_stub = stub(extension_point_type: @ep_type)
        ShopifyCli::ScriptModule::ScriptProject.stubs(:current).returns(project_stub)

        @cmd = ShopifyCli::Commands::Unpublish
        @cmd.ctx = @context
        @cmd_name = 'unpublish'
      end

      def test_calls_application_unpublish
        api_key = 'key'
        shop_id = '1'
        @cmd.expects(:authenticate_partner_identity).with(@context)
        ShopifyCli::ScriptModule::Application::Unpublish.expects(:call).with(
          @context,
          api_key,
          shop_id,
          @ep_type
        )
        capture_io do
          @cmd.call(['--api_key', api_key, '--shop_id', shop_id], @cmd_name)
        end
      end
    end
  end
end
