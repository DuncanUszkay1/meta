require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      require 'shopify-cli/commands/create/script'

      class ScriptTest < MiniTest::Test
        include TestHelpers::Errors

        def setup
          super
          ENV.stubs(:[]).returns('true')
          @cmd = ShopifyCli::Commands::Create::Script.new
          @cmd.ctx = @context
          @script_name = 'script_name'
          @ep_name = 'discount'
          @ep = ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new
            .get_extension_point(@ep_name)
          ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.any_instance
            .expects(:get_extension_point)
            .with(@ep_name)
            .returns(@ep)
          @cmd.options = Class.new
          @cmd.options.stubs(:flags).returns({ ep_name: @ep_name })
          @language = 'ts'
        end

        def test_can_create_new_script
          ShopifyCli::ScriptModule::ScriptProject.expects(:create).with(@script_name)

          ScriptModule::Application::Bootstrap.expects(:call)
            .with(
              @context,
              @language,
              @ep,
              @script_name,
              ShopifyCli::Commands::Create::Script::OPERATION_FAILED_MESSAGE
            )
            .returns(
              ShopifyCli::ScriptModule::Domain::Script.new('id', @script_name, @ep_name, @language)
            )

          capture_io { call_create }
        end

        private

        def call_create
          @cmd.call([@script_name], 'create')
        end
      end
    end
  end
end
