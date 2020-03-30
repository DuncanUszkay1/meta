# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptRepository do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }
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
  let(:language) { "ts" }
  let(:script_folder_base) { "/some/directory#{script_name}" }
  let(:script_source_base) { "#{script_folder_base}/src" }
  let(:script_source_file) { "#{script_source_base}/script.#{language}" }
  let(:script_schema_file) { "#{script_source_base}/#{extension_point_type}.schema" }
  let(:expected_script_id) { "src/#{script_name}.#{language}" }
  let(:template_base) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/templates/" }
  let(:template_file) { "#{template_base}/typescript/#{extension_point_type}.#{language}" }
  let(:as_sdk_path) do
    "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/sdk/as"
  end
  let(:script_repository) { ShopifyCli::ScriptModule::Infrastructure::ScriptRepository.new }
  let(:project) { TestHelpers::FakeProject.new }

  before do
    FileUtils.mkdir_p(script_folder_base)
    ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository
      .stubs(:new)
      .returns(extension_point_repository)
    ShopifyCli::ScriptModule::ScriptProject.stubs(:current).returns(project)
    project.directory = script_folder_base
  end

  describe ".create_script" do
    subject { script_repository.create_script(language, extension_point, script_name) }
    it "should call the bootstrap method and return the script" do
      CLI::Kit::System.expects(:capture2e)
        .with("npx shopify-scripts-bootstrap src //myscript/src")
        .returns(["", OpenStruct.new(success?: true)])
      script = subject
      assert_equal expected_script_id, script.id
      assert_equal script_name, script.name
      assert_equal extension_point_type, script.extension_point_type
    end
  end

  describe ".get_script" do
    subject { script_repository.get_script(language, extension_point.type, script_name) }

    describe "when extension point is valid" do
      it "should return the requested script" do
        FileUtils.mkdir_p(script_source_base)
        File.write(script_source_file, "//script code")
        script = subject
        assert_equal expected_script_id, script.id
        assert_equal script_name, script.name
        assert_equal extension_point_type, script.extension_point_type
      end

      it "should raise ScriptNotFoundError when script source file does not exist" do
        FileUtils.mkdir_p(script_source_base)
        e = assert_raises(ShopifyCli::ScriptModule::Domain::ScriptNotFoundError) { subject }
        assert_equal script_source_file, e.script_name
      end
    end
  end

  describe ".with_temp_build_context" do
    let(:script_file) { "#{extension_point.type}.#{language}" }
    let(:helper_file) { "helper.#{language}" }

    before do
      FileUtils.mkdir_p(script_source_base)
      Dir.chdir(script_source_base)
      File.write(script_file, "//run code")
    end

    it "should go to a tempdir with all its files" do
      File.write(helper_file, "//helper code")
      FileUtils.mkdir_p("other_dir")

      script_repository.with_temp_build_context do
        refute_equal script_source_base, Dir.pwd
        assert File.exist?(script_file)
        assert File.exist?(helper_file)
      end
    end

    it "should create temp directory in the script root" do
      nested_dir = "#{script_folder_base}/some/nested/directory"
      FileUtils.mkdir_p(nested_dir)
      Dir.chdir(nested_dir)

      temp_dir = "#{script_folder_base}/temp"
      script_repository.with_temp_build_context do
        assert_equal Dir.pwd, temp_dir
      end
    end

    it "should delete the script root temp directory afterwards" do
      temp_dir = "#{script_folder_base}/temp"
      script_repository.with_temp_build_context do
        assert Dir.exist?(temp_dir)
      end
      refute Dir.exist?(temp_dir)
    end
  end
end
