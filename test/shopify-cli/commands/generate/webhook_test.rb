require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class WebhookTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
          @cmd = ShopifyCli::Commands::Generate
          @cmd.ctx = @context
          @cmd_name = 'generate'
        end

        def test_with_param
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
          )
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          @cmd.call(['webhook', 'PRODUCT_CREATE'], @cmd_name)
        end

        def test_with_selection
          ShopifyCli::Tasks::Schema.expects(:call).returns(
            JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json"))),
          )
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with('a command')
            .returns(mock(success?: true))
          @cmd.call(['webhook'], @cmd_name)
        end
      end
    end
  end
end
