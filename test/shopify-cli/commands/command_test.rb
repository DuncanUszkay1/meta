require 'test_helper'

module ShopifyCli
  module Commands
    class CommandTest < MiniTest::Test
      include TestHelpers::Constants

      def setup
        super
        ShopifyCli::Project.stubs(:current_context).returns(:top_level)
        load_cmd
      end

      def test_non_existant
        io = capture_io do
          assert_raises(ShopifyCli::AbortSilent) do
            run_cmd('foobar')
          end
        end

        assert_match(/foobar.*was not found/, io.join)
      end

      def test_calls_help_with_h_flag
        io = capture_io do
          @cmd.call(['-h'], @cmd_name)
        end

        help_io = capture_io do
          help = Commands::Help.new(@context)
          help.call(['create'], nil)
        end
        assert_match(help_io.join, io.join)
      end

      def test_calls_help_with_subcommand_h_flag
        cmd_io = capture_io do
          @cmd.call(['app', '-h'], @cmd_name)
        end

        help_io = capture_io do
          help = Commands::Help.new(@context)
          help.call(['app'], nil)
        end

        assert_match(help_io.join, cmd_io.join)
      end

      def load_cmd
        reload_class
        @cmd = ShopifyCli::Commands::Create
        @cmd.ctx = @context
        @cmd_name = 'create'
      end

      def reload_class
        ignore_constant_redefined_warnings do
          ShopifyCli::Commands.send(:remove_const, :Create)
          load('shopify-cli/commands/create.rb')
          load('shopify-cli/commands/create/app.rb')
          load('shopify-cli/commands/create/script.rb')
        end
      end
    end
  end
end
