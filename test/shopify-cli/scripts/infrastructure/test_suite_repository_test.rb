# frozen_string_literal: true

require "test_helper"
require_relative "fake_script_repository"

describe ShopifyCli::ScriptModule::Infrastructure::TestSuiteRepository do
  include TestHelpers::FakeFS

  let(:extension_point_type) { "discount" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
        "sdk-version": "*"
      }
    }
  end
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:script_name) { "myscript" }
  let(:context) { TestHelpers::FakeContext.new }
  let(:language) { "ts" }
  let(:script_id) { 'id' }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_id, script_name, extension_point, language) }
  let(:template_base) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/templates" }
  let(:template_file) do
    "#{template_base}/ts/#{ShopifyCli::ScriptModule::Infrastructure::TestSuiteRepository::TEST_TEMPLATE_NAME}"\
    ".spec.#{language}"
  end
  let(:config_file) { "#{template_base}/ts/as-pect.config.js" }
  let(:spec_test_base) { "#{script_name}/test" }
  let(:spec_test_file) { "#{spec_test_base}/script.spec.#{language}" }
  let(:script_repository) { ShopifyCli::ScriptModule::Infrastructure::FakeScriptRepository.new }
  let(:repository) { ShopifyCli::ScriptModule::Infrastructure::TestSuiteRepository.new }
  let(:project) { TestHelpers::FakeProject.new }

  before do
    ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
      .stubs(:new)
      .returns(script_repository)
    ShopifyCli::ScriptModule::ScriptProject.stubs(:current).returns(project)
    project.directory = script_name
  end

  describe ".create_test_suite" do
    subject { repository.create_test_suite(script) }

    it "should create a test suite" do
      FakeFS::FileSystem.clone(config_file)
      CLI::Kit::System.expects(:capture2e)
        .with("npx shopify-scripts-bootstrap test myscript/test")
        .returns(["", OpenStruct.new(success?: true)])
      subject
    end
  end

  describe ".get_test_suite" do
    subject { repository.get_test_suite(language, extension_point_type, script_name) }

    describe "when script is valid" do
      before do
        script_repository.create_script(language, extension_point, script_name)
      end

      it "should check that the script exists" do
        File.expects(:exist?).with("myscript/test/script.spec.ts").returns(true)
        script_repository.expects(:get_script).with("ts", "discount", "myscript")
        subject
      end

      it "should do nothing if test spec file exists" do
        File.expects(:exist?).with("myscript/test/script.spec.ts").returns(true)
        subject
      end

      it "should raise TestSuiteNotFoundError if test spec file does not exist" do
        assert_raises(ShopifyCli::ScriptModule::Domain::TestSuiteNotFoundError) { subject }
      end
    end
  end

  describe ".with_test_suite_context" do
    it "should allow execution at the correct place within the filesystem" do
      FileUtils.mkdir_p(spec_test_base)
      repository.with_test_suite_context do
        assert_equal "/#{spec_test_base}", Dir.pwd
      end
    end
  end
end
