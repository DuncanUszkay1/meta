# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptRepository do
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("id", "discount", "schema") }
  let(:script_name) { "myscript" }
  let(:language) { "ts" }
  let(:source_path) { ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH }
  let(:template_source_path) { ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH }
  let(:script_source_base) { "#{source_path}/#{extension_point.type}/#{script_name}" }
  let(:templates_base_path) { "#{template_source_path}/templates" }
  let(:schemas_base_path) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/schemas" }

  subject { ShopifyCli::ScriptModule::Infrastructure::ScriptRepository.new }

  describe ".create_script" do
    it "creates the script code template the script source directory" do
      ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
        .any_instance
        .expects(:create_configuration)
        .returns(MiniTest::Mock.new)

      FakeFS do
        FakeFS::FileSystem.clone("#{templates_base_path}/typescript/#{extension_point.type}.ts")
        FakeFS::FileSystem.clone("#{schemas_base_path}/shopify_runtime_types.ts")
        FileUtils.mkdir_p(script_source_base)

        subject.create_script(language, extension_point, script_name)

        assert File.exist?("#{script_source_base}/#{script_name}.ts")
        assert File.exist?("#{script_source_base}/shopify_runtime_types.ts")
      end
    end

    it "creates a Script domain entity with the attributes correctly set" do
      ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
        .any_instance
        .expects(:create_configuration)
        .returns(MiniTest::Mock.new)

      FileUtils.stubs(:cp_r)
      script = subject.create_script(language, extension_point, script_name)
      assert_equal "#{script_source_base}/#{script_name}.#{language}", script.id
      assert_equal script_name, script.name
      assert_equal extension_point, script.extension_point
    end
  end

  describe ".get_script" do
    it "should return the requested script" do
      ShopifyCli::ScriptModule::Infrastructure::ConfigurationRepository
        .any_instance
        .expects(:get_configuration)
        .returns(MiniTest::Mock.new)

      File.expects(:exist?)
        .with("#{script_source_base}/#{script_name}.#{language}")
        .returns(true)

      script = subject.get_script(language, extension_point, script_name)
      assert_equal "#{script_source_base}/#{script_name}.#{language}", script.id
    end

    it "should raise ScriptNotFoundError if it can't find the script" do
      File.expects(:exist?)
        .with("#{script_source_base}/#{script_name}.#{language}")
        .returns(false)

      assert_raises ShopifyCli::ScriptModule::Domain::ScriptNotFoundError do
        subject.get_script(language, extension_point, script_name)
      end
    end
  end
end
