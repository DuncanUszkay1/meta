# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ConfigurationRepository do
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("foo", "discount", "schema") }
  let(:script) do
    config = MiniTest::Mock.new
    ShopifyCli::ScriptModule::Domain::Script.new("foo", "discount_script", extension_point, config, "ts")
  end
  let(:configuration_root) do
    source_path = ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH
    "#{source_path}/#{extension_point.type}/#{script.name}/configuration"
  end
  let(:schema_source) { "#{configuration_root}/config.schema" }
  let(:types_source) { "#{configuration_root}/configuration.#{script.language}" }

  let(:configuration_schema_template) do
    installation_path = ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH
    "#{installation_path}/templates/configuration/config.schema"
  end

  let(:configuration) do
    ShopifyCli::ScriptModule::Domain::Configuration.new(
      schema_source, "schema"
    )
  end

  subject { ShopifyCli::ScriptModule::Infrastructure::ConfigurationRepository.new }

  describe ".create_configuration" do
    it "should create a default configuration file and derive the corresponding types" do
      FakeFS do
        FakeFS::FileSystem.clone(configuration_schema_template)
        config = subject.create_configuration(extension_point, script.name)
        assert File.directory?(configuration_root)
        assert File.exist?(schema_source)
        assert File.exist?(types_source)

        assert_equal schema_source, config.id
      end
    end
  end

  describe ".get_configuration" do
    it "should return a configuration domain element" do
      FakeFS do
        FakeFS::FileSystem.clone(configuration_schema_template)
        FileUtils.mkdir_p(configuration_root)
        FileUtils.cp_r(configuration_schema_template, configuration_root)

        conf = subject.get_configuration(extension_point, script.name)

        assert_equal schema_source, conf.id
      end
    end
  end

  describe ".generate_configuration_types_from_schema" do
    it "should derive configuration types from the schema config file" do
      extension_point_repo = ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository
      extension_point_repo.any_instance
        .expects(:get_extension_point)
        .returns(extension_point)

      FakeFS do
        FakeFS::FileSystem.clone(configuration_schema_template)
        subject.create_configuration(extension_point, script.name)
        subject.generate_configuration_types_from_schema(
          extension_point.type, script.name
        )

        assert File.exist?(types_source)
      end
    end
  end
end
