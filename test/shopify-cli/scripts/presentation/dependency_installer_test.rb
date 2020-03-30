# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Presentation::DependencyInstaller do
  describe ".call" do
    let(:ctx) { TestHelpers::FakeContext.new }
    let(:script_name) { "foo_discount" }
    let(:language) { "ts" }
    let(:extension_point) { OpenStruct.new }
    let(:failed_op_message) { "Operation failed." }
    subject do
      capture_io do
        ShopifyCli::ScriptModule::Presentation::DependencyInstaller.call(
          ctx,
          language,
          extension_point,
          script_name,
          failed_op_message
        )
      end
    end

    describe "when dependencies are already installed" do
      before do
        ShopifyCli::ScriptModule::Application::ProjectDependencies.stubs(:installed?).returns(true)
      end

      it "should skip installation" do
        ShopifyCli::ScriptModule::Application::ProjectDependencies.expects(:install).never
        subject
      end
    end

    describe "when dependencies are not already installed" do
      before do
        ShopifyCli::ScriptModule::Application::ProjectDependencies.stubs(:installed?).returns(false)
      end

      describe "when dependency installer succeeds" do
        it "dependencies should be installed" do
          ShopifyCli::ScriptModule::Application::ProjectDependencies.expects(:install)
            .with(ctx, language, extension_point, script_name)
          ShopifyCli::UI::ErrorHandler.expects(:display_and_raise).never
          subject
        end
      end

      describe "when dependency installer fails" do
        let(:error_message) { 'some message' }
        before do
          ShopifyCli::ScriptModule::Application::ProjectDependencies.stubs(:install).raises(
            ShopifyCli::ScriptModule::Infrastructure::DependencyInstallError, error_message
          )
        end

        it "error message should be displayed" do
          ctx.expects(:puts).with("\n#{error_message}")
          ShopifyCli::UI::ErrorHandler.expects(:display_and_raise)
          subject
        end
      end
    end
  end
end
