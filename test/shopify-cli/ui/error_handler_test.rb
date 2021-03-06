# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::UI::ErrorHandler do
  describe ".display_and_raise" do
    let(:failed_op) { "Operation didn't complete." }
    let(:cause_of_error) { "This is why it failed." }
    let(:help_suggestion) { "Perhaps this is what's wrong." }
    subject do
      ShopifyCli::UI::ErrorHandler.display_and_raise(
        failed_op: failed_op, cause_of_error: cause_of_error, help_suggestion: help_suggestion
      )
    end

    describe "when failed operation message, cause of error, and help suggestion are all provided" do
      it "should abort with the cause of error and help suggestion" do
        $stderr.expects(:puts).with("\e[0;31m✗ Error\e[0m")
        $stderr.expects(:puts).with("\e[0m#{failed_op} #{cause_of_error} #{help_suggestion}")
        assert_raises(ShopifyCli::AbortSilent) do
          subject
        end
      end
    end

    describe "when failed operation message is missing" do
      let(:failed_op) { nil }
      it "should abort with the cause of error and help suggestion" do
        $stderr.expects(:puts).with("\e[0;31m✗ Error\e[0m")
        $stderr.expects(:puts).with("\e[0m#{cause_of_error} #{help_suggestion}")
        assert_raises(ShopifyCli::AbortSilent) do
          subject
        end
      end
    end

    describe "when cause of error is missing" do
      let(:cause_of_error) { nil }
      it "should abort with the failed operation message and help suggestion" do
        $stderr.expects(:puts).with("\e[0;31m✗ Error\e[0m")
        $stderr.expects(:puts).with("\e[0m#{failed_op} #{help_suggestion}")
        assert_raises(ShopifyCli::AbortSilent) do
          subject
        end
      end
    end

    describe "when help suggestion is missing" do
      let(:help_suggestion) { nil }
      it "should abort with the failed operation message and cause of error" do
        $stderr.expects(:puts).with("\e[0;31m✗ Error\e[0m")
        $stderr.expects(:puts).with("\e[0m#{failed_op} #{cause_of_error}")
        assert_raises(ShopifyCli::AbortSilent) do
          subject
        end
      end
    end
  end

  describe ".pretty_print_and_raise" do
    let(:err) { nil }
    let(:failed_op) { 'message' }
    subject { ShopifyCli::UI::ErrorHandler.pretty_print_and_raise(err, failed_op: failed_op) }

    describe "when exception is not in list" do
      let(:err) { StandardError.new }

      it "should raise" do
        assert_raises(StandardError) { subject }
      end
    end

    describe "when exception is listed" do
      def should_call_display_and_raise
        ShopifyCli::UI::ErrorHandler.expects(:display_and_raise).once
        subject
      end

      describe "when Errno::EACCESS" do
        let(:err) { Errno::EACCES.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when Errno::ENOSPC" do
        let(:err) { Errno::ENOSPC.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when Oauth::Error" do
        let(:err) { ShopifyCli::OAuth::Error.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when GraphqlError" do
        let(:err) { ShopifyCli::ScriptModule::Infrastructure::GraphqlError.new('', []) }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ForbiddenError" do
        let(:err) { ShopifyCli::ScriptModule::Infrastructure::ForbiddenError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end
    end
  end
end
