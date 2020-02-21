require 'test_helper'

module ShopifyCli
  module Commands
    class Deploy
      require 'shopify-cli/commands/deploy/script'

      class ScriptTest < MiniTest::Test
        def setup
          super
          @cmd = ShopifyCli::Commands::Deploy::Script
          @cmd.ctx = @context
          @language = 'ts'
          @extension_point_type = 'discount'
          @script_name = 'script name'
        end

        def test_deploy_is_forced_when_flag_is_present
          cmd = new_command_with_options('--force')
          expect_deploy_with_force(cmd, true)
        end

        def test_deploy_is_not_forced_when_flag_is_not_present
          cmd = new_command_with_options
          expect_deploy_with_force(cmd, nil)
        end

        def test_build_script_calls_error_handler_when_build_fails
          cmd = new_command_with_options
          err_msg = 'some error message'

          ScriptModule::Application::Build.stubs(:call).raises(StandardError, err_msg)
          io = capture_io do
            ShopifyCli::UI::ErrorHandler.expects(:display_and_raise)
            cmd.send(:build_script, @language, @extension_point_type, @script_name)
          end
          output = io.join
          assert_match(err_msg, output)
        end

        def test_build_script_returns_normal_when_build_succeeds
          cmd = new_command_with_options
          ScriptModule::Application::Build.stubs(:call).returns(true)
          capture_io do
            ShopifyCli::UI::ErrorHandler.expects(:display_and_raise).never
            cmd.send(:build_script, @language, @extension_point_type, @script_name)
          end
        end

        private

        def expect_deploy_with_force(cmd, force)
          ScriptModule::Application::Deploy.expects(:call).with(
            @context, @language, @extension_point_type, @script_name, @api_key, force
          )
          cmd.send(:deploy_script, @language, @extension_point_type, @script_name, @api_key)
        end

        def new_command_with_options(*options)
          cmd = @cmd.new
          cmd.ctx = @context
          cmd.options = Options.new
          cmd.options.parse(@cmd.instance_variable_get(:@_options), options)
          cmd
        end
      end
    end
  end
end
