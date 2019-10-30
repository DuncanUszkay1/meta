# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository do
  subject { ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new(script_service) }
  let(:source_path) { ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH }
  let(:script_service) { MiniTest::Mock.new }

  describe ".get_extension_point" do
    let(:extension_points) { [{ "name" => remote_extension, "schema" => discount_schema }] }
    let(:schema_root) { "#{source_path}/#{extension}/#{script_name}/types" }
    let(:discount_schema) do
      <<~HEREDOC
        type Money {
          subunits: Int!
          iso_currency: String!
        }

        input MoneyInput {
          subunits: Int!
          iso_currency: String!
        }

        input MultiCurrencyRequest {
          money: MoneyInput!
          presentment_currency: String
          shop_currency: String
        }

        type Query {
          run(root: MultiCurrencyRequest!): Money!
        }

        schema { query: Query }
      HEREDOC
    end

    let(:remote_extension) { "discount" }
    let(:extension) { remote_extension }
    let(:script_name) { "bar" }
    let(:extension_point_id) { "#{source_path}/#{extension}/#{script_name}/types/#{extension}.schema" }

    describe "if the right schema file exists" do
      before do
        File.expects(:exist?).with(extension_point_id).returns(true)
        File.expects(:read).with(extension_point_id).returns("schema")
      end

      it "should return valid ExtensionPoint" do
        extension_point = subject.get_extension_point(extension, script_name)
        assert_equal "schema", extension_point.schema
        assert_equal extension, extension_point.type
        assert_equal extension_point_id, extension_point.id
      end
    end

    describe "if the right schema file does not exist" do
      before do
        script_service.expect(:fetch_extension_points, extension_points)
      end

      describe "if the script_service has the schema remotely" do
        it "should persist the extension point at the correct file path" do
          schema_types = ShopifyCli::ScriptModule::Infrastructure::GraphQLTypeScriptBuilder.new(discount_schema).build

          FileUtils.expects(:mkdir_p).with(schema_root)
          File.expects(:write).with("#{schema_root}/#{extension}.schema", discount_schema)
          File.expects(:write).with("#{schema_root}/#{extension}.ts", schema_types)

          extension_point = subject.get_extension_point(extension, script_name)
          assert_equal "#{schema_root}/#{extension}.schema", extension_point.id
        end
      end

      describe "if the script_service does not have the schema remotely" do
        let(:extension) { "bogus" }
        it "should raise an ArgumentError" do
          err = assert_raises ShopifyCli::ScriptModule::Domain::InvalidExtensionPointError do
            subject.get_extension_point(extension, script_name)
          end
          assert_equal "Extension point #{extension} cannot be found", err.message
        end
      end
    end
  end
end
