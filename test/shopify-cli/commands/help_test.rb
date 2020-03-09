require 'test_helper'

module ShopifyCli
  module Commands
    class FakeCommand < ShopifyCli::Command
      class << self
        def help
          "basic help"
        end

        def extended_help
          "extended help"
        end
      end
    end

    class HelpTest < MiniTest::Test
      def setup
        ShopifyCli::Commands.register(:FakeCommand, 'fake')
      end

      def test_default_behavior_lists_tasks
        io = capture_io do
          run_cmd('help')
        end
        output = io.join

        assert_match('Available commands', output)
        assert_match(/Usage: .*shopify/, output)
      end

      def test_extended_help_for_individual_command
        io = capture_io do
          run_cmd('help fake')
        end
        output = io.join
        assert_match(/basic help.*extended help/m, output)
      end

      def test_prints_command_not_found_for_invalid_command
        command = 'does_not_exist'
        ShopifyCli::Commands::Help.any_instance.expects(:print_not_found).with(command)
        capture_io do
          run_cmd("help #{command}")
        end
      end

      def test_prints_command_not_found_for_command_outside_of_current_context
        command = 'does_not_exist'
        ShopifyCli::Commands::Registry.stubs(:exist?).with(command).returns(true)
        ShopifyCli::Commands::Help.any_instance.expects(:print_not_found).with(command)
        capture_io do
          run_cmd("help #{command}")
        end
      end
    end
  end
end
