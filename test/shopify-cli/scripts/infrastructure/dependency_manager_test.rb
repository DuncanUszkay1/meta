# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::DependencyManager do
  describe ".for" do
    let(:script_name) { "foo_discount" }
    let(:ctx) { TestHelpers::FakeContext.new }
    let(:extension_point_config) do
      {
        "assemblyscript" => {
          "package": "@shopify/extension-point-as-fake",
          "version": "*",
          "sdk-version": "*"
        }
      }
    end
    let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("discount", extension_point_config) }
    subject { ShopifyCli::ScriptModule::Infrastructure::DependencyManager.for(ctx, language, extension_point, script_name) }

    describe "when the script language does match an entry in the registry" do
      let(:language) { "ts" }

      it "should return the entry from the registry" do
        assert_instance_of(ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager, subject)
      end
    end

    describe "when the script language doesn't match an entry in the registry" do
      let(:language) { "ArnoldC" }

      it "should raise dependency not supported error" do
        assert_raises(ShopifyCli::ScriptModule::Infrastructure::DependencyError,
                      "{{x}} No dependency support for #{language}") { subject }
      end
    end
  end
end
