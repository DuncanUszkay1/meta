# frozen_string_literal: true

module TestHelpers
  module Errors
    def assert_silent_abort_when_raised(stub, error)
      stub.raises(error)

      assert_raises(ShopifyCli::AbortSilent) do
        capture_io do
          yield
        end
      end
    end
  end
end
