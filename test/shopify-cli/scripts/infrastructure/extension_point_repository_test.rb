# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository do
  subject { ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new }

  describe ".get_extension_point" do
    describe "when the extension point is configured" do
      ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new
        .send(:load_extension_points_yaml)
        .each do |extension_point_type, _config|
          it "should be able to load the #{extension_point_type} extension point" do
            extension_point = subject.get_extension_point(extension_point_type)
            assert_equal extension_point_type, extension_point.type
            refute_nil extension_point.sdks[:ts].package
            refute_nil extension_point.sdks[:ts].version
            refute_nil extension_point.sdks[:ts].sdk_version
          end
        end
    end

    describe "when the extension point does not exist" do
      let(:bogus_extension) { "bogus" }

      it "should raise Domain::InvalidExtensionPointError" do
        assert_raises(ShopifyCli::ScriptModule::Domain::InvalidExtensionPointError) do
          subject.get_extension_point(bogus_extension)
        end
      end
    end
  end
end
