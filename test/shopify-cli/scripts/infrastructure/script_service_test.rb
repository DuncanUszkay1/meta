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
      query ProxyRequest($api_key: String, $query: String!, $variables: String) {
        scriptServiceProxy(
          apiKey: $api_key
          query: $query
          variables: $variables
        )
      }
    HERE
  end

  describe ".fetch_extension_points" do
    let(:valid_ep_response) do
      {
        "data" => {
          "extensionPoints" => [
            {
              "name" => "ALLOW_CHECKOUT_COMPLETION",
              "schema" => "schema",
              "types" => "types",
              "scriptExample" => "var i = 0",
            },
            {
              "name" => extension_point_type,
              "schema" => "schema",
              "types" => "type",
              "scriptExample" => "var i = 0",
            },
          ],
        },
      }
    end

    let(:extension_point_query) do
      <<~HERE
        query GetExtensionPoints {
          extensionPoints {
            name
            schema
            scriptExample
            types
          }
        }
      HERE
    end

    subject { script_service.fetch_extension_points }
    it "should return an array of available extension points" do
      stub_load_query('script_service_proxy', script_service_proxy)
      stub_load_query('get_extension_points', extension_point_query)
      stub_partner_req(
        'script_service_proxy',
        variables: {
          query: extension_point_query,
          api_key: nil,
        },
        resp: {
          data: {
            scriptServiceProxy: JSON.dump(valid_ep_response),
          },
        }
      )

      assert_equal(valid_ep_response, subject)
    end
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
            scriptServiceProxy: JSON.dump("errors" => "errors"),
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
          errors: 'some error message',
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
end
