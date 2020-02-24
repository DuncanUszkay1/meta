require 'test_helper'

module ShopifyCli
  class SmokeTest < MiniTest::Test
    def test_exit_non_zero
      Project.stubs(:current_context).returns(:app)
      assert_nothing_raised do
        capture_io do
          ShopifyCli::EntryPoint.call(['help'])
        end
      end
    end
  end
end
