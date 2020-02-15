# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::UI::ErrorHandler do
  describe ".display_and_raise" do
    let(:failed_op) { "This operation did not complete." }
    let(:cause_of_error) { "This is why it failed." }
    let(:help_suggestion) { "Perhaps this is what's wrong." }
    subject do
      ShopifyCli::UI::ErrorHandler.display_and_raise(
        failed_op: failed_op, cause_of_error: cause_of_error, help_suggestion: help_suggestion
      )
    end

    describe "when failed operation message, cause of error, and help suggestion are all provided" do
      it "should abort with the cause of error and help suggestion" do
        err_msg = capture_io do
          assert_raises(ShopifyCli::AbortSilent) do
            subject
          end
        end
        expected_err_msg = "\e[0;31m✗ Error\e[0m#{failed_op}  #{cause_of_error}  #{help_suggestion}"
        assert_equal(expected_err_msg, err_msg[1])
      end
    end

    describe "when failed operation message is missing" do
      let(:failed_op) { nil }
      it "should abort with the cause of error and help suggestion" do
        err_msg = capture_io do
          assert_raises(ShopifyCli::AbortSilent) do
            subject
          end
        end

        expected_err_msg = "\e[0;31m✗ Error\e[0m#{cause_of_error}  #{help_suggestion}"
        assert_equal(expected_err_msg, err_msg[1])
      end
    end

    describe "when cause of error is missing" do
      let(:cause_of_error) { nil }
      it "should abort with the failed operation message and help suggestion" do
        err_msg = capture_io do
          assert_raises(ShopifyCli::AbortSilent) do
            subject
          end
        end

        expected_err_msg = "\e[0;31m✗ Error\e[0m#{failed_op}  #{help_suggestion}"
        assert_equal(expected_err_msg, err_msg[1])
      end
    end

    describe "when help suggestion is missing" do
      let(:help_suggestion) { nil }
      it "should abort with the failed operation message and cause of error" do
        err_msg = capture_io do
          assert_raises(ShopifyCli::AbortSilent) do
            subject
          end
        end

        expected_err_msg = "\e[0;31m✗ Error\e[0m#{failed_op}  #{cause_of_error}"
        assert_equal(expected_err_msg, err_msg[1])
      end
    end
  end
end
