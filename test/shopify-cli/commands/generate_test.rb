require 'test_helper'

module ShopifyCli
  module Commands
    class GenerateTest < MiniTest::Test

      def setup
        super
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        @cmd = ShopifyCli::Commands::Generate
        @cmd.ctx = @context
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Generate.help)
        @cmd.call([], 'generate')
      end

      def test_for_failure
        m = mock
        m.stubs(:success?).returns(false)
        m.stubs(:exitstatus).returns(1)
        @context.expects(:system).with(
          [
            'npm',
            'run-dev',
            'run-script',
            'generate-page',
            '--silent',
          ]
        ).returns(m)
        assert_raises(ShopifyCli::Abort) do
          ShopifyCli::Commands::Generate.run_generate(
            [
              'npm',
              'run-dev',
              'run-script',
              'generate-page',
              '--silent',
            ], 'test', @context
          )
        end
      end
    end
  end
end
