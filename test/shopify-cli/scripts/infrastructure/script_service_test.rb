# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptService do
  include TestHelpers::Partners

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:script_service) { ShopifyCli::ScriptModule::Infrastructure::ScriptService.new(ctx: ctx) }
  let(:api_key) { "fake_key" }
  let(:extension_point_type) { "DISCOUNT" }
  let(:script_service_proxy) do
    <<~HERE
      query ProxyRequest($api_key: String, $shop_id: Int, $query: String!, $variables: String) {
        scriptServiceProxy(
          apiKey: $api_key
          shopId: $shop_id
          query: $query
          variables: $variables
        )
      }
    HERE
  end

  describe ".deploy" do
    let(:extension_point_schema) { "schema" }
    let(:script_name) { "foo_bar" }
    let(:script_content) { "(module)" }
    let(:content_type) { "ts" }
    let(:api_key) { "fake_key" }
    let(:schema) { "schema" }
    let(:app_script_update_or_create) do
      <<~HERE
        mutation AppScriptUpdateOrCreate(
          $extensionPointName: ExtensionPointName!,
          $title: String,
          $sourceCode: String,
          $language: String,
          $schema: String
        ) {
          appScriptUpdateOrCreate(
            extensionPointName: $extensionPointName
            title: $title
            sourceCode: $sourceCode
            language: $language
            schema: $schema
        ) {
            userErrors {
              field
              message
            }
            appScript {
              appKey
              configSchema
              extensionPointName
              title
            }
          }
        }
      HERE
    end

    before do
      stub_load_query('script_service_proxy', script_service_proxy)
      stub_load_query('app_script_update_or_create', app_script_update_or_create)
      stub_partner_req(
        'script_service_proxy',
        variables: {
          query: app_script_update_or_create,
          api_key: api_key,
          variables: {
            extensionPointName: extension_point_type,
            title: script_name,
            sourceCode: Base64.encode64(script_content),
            language: "ts",
            schema: extension_point_schema,
            force: false,
          }.to_json,
        },
        resp: response
      )
    end

    subject do
      script_service.deploy(
        extension_point_type: extension_point_type,
        schema: extension_point_schema,
        script_name: script_name,
        script_content: script_content,
        compiled_type: "ts",
        api_key: api_key,
      )
    end

    describe "when deploy to script service succeeds" do
      let(:script_service_response) do
        {
          "data" => {
            "appScriptUpdateOrCreate" => {
              "appScript" => {
                "apiKey" => "fake_key",
                "configSchema" => nil,
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
              },
              "userErrors" => [],
            },
          },
        }
      end

      let(:response) do
        {
          data: {
            scriptServiceProxy: JSON.dump(script_service_response),
          },
        }
      end

      it "should post the form without scope" do
        assert_equal(script_service_response, subject)
      end
    end

    describe "when deploy to script service responds with errors" do
      let(:response) do
        {
          data: {
            scriptServiceProxy: JSON.dump("errors" => [{ message: "errors" }]),
          },
        }
      end

      it "should raise error" do
        assert_raises(ShopifyCli::ScriptModule::Infrastructure::GraphqlError) { subject }
      end
    end

    describe "when partners responds with errors" do
      let(:response) do
        {
          errors: [{ message: "some error message" }],
        }
      end

      it "should raise error" do
        assert_raises(ShopifyCli::ScriptModule::Infrastructure::GraphqlError) { subject }
      end
    end

    describe "when deploy to script service responds with userErrors" do
      describe "when invalid app key" do
        let(:response) do
          {
            data: {
              scriptServiceProxy: JSON.dump(
                "data" => {
                  "appScriptUpdateOrCreate" => {
                    "userErrors" => [{ "message" => "invalid", "field" => "appKey", "tag" => "user_error" }],
                  },
                }
              ),
            },
          }
        end

        it "should raise error" do
          assert_raises(ShopifyCli::ScriptModule::Infrastructure::ScriptServiceUserError) { subject }
        end
      end

      describe "when redeploy without a force" do
        let(:response) do
          {
            data: {
              scriptServiceProxy: JSON.dump(
                "data" => {
                  "appScriptUpdateOrCreate" => {
                    "userErrors" => [{ "message" => "error", "tag" => "already_exists_error" }],
                  },
                }
              ),
            },
          }
        end

        it "should raise ScriptRedeployError error" do
          assert_raises(ShopifyCli::ScriptModule::Infrastructure::ScriptRedeployError) { subject }
        end
      end
    end
  end

  describe ".disable" do
    let(:extension_point_type) { "DISCOUNT" }
    let(:shop_id) { '1' }
    let(:api_key) { "fake_key" }
    let(:shop_script_delete) do
      <<~HERE
        mutation ShopScriptDelete($extensionPointName: ExtensionPointName!) {
          shopScriptDelete(extensionPointName: $extensionPointName) {
            userErrors {
              field
              message
              tag
            }
            shopScript {
              extensionPointName
              shopId
              title
              configuration
            }
          }
        }
      HERE
    end

    let(:response) do
      {
        data: {
          scriptServiceProxy: JSON.dump(script_service_response),
        },
      }
    end

    before do
      stub_load_query('script_service_proxy', script_service_proxy)
      stub_load_query('shop_script_delete', shop_script_delete)
      stub_partner_req(
        'script_service_proxy',
        variables: {
          query: shop_script_delete,
          api_key: api_key,
          shop_id: shop_id,
          variables: {
            extensionPointName: extension_point_type,
          }.to_json,
        },
        resp: response
      )
    end

    subject do
      script_service.disable(
        extension_point_type: extension_point_type,
        api_key: api_key,
        shop_id: shop_id,
      )
    end

    describe 'when successful' do
      let(:script_service_response) do
        {
          "data" => {
            "shopScriptDelete" => {
              "shopScript" => {
                "shopId" => "1",
                "configuration" => nil,
                "extensionPointName" => extension_point_type,
                "title" => "foo2",
              },
              "userErrors" => [],
            },
          },
        }
      end

      it 'should have no errors' do
        assert_equal(script_service_response, subject)
      end
    end

    describe 'when failure' do
      describe 'when shop_script_not_found error' do
        let(:script_service_response) do
          {
            "data" => {
              "shopScriptDelete" => {
                "shopScript" => {},
                "userErrors" => [{ "message" => 'error', "tag" => "shop_script_not_found" }],
              },
            },
          }
        end

        it 'should raise ShopScriptUndefinedError' do
          assert_raises(ShopifyCli::ScriptModule::Infrastructure::ShopScriptUndefinedError) { subject }
        end
      end

      describe 'when other error' do
        let(:script_service_response) do
          {
            "data" => {
              "shopScriptDelete" => {
                "shopScript" => {},
                "userErrors" => [{ "message" => 'error', "tag" => "other_error" }],
              },
            },
          }
        end

        it 'should raise ShopScriptUndefinedError' do
          assert_raises(ShopifyCli::ScriptModule::Infrastructure::ScriptServiceUserError) { subject }
        end
      end
    end
  end
end
