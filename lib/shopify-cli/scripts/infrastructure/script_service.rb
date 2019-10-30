# frozen_string_literal: true

require "shopify_cli"
require "net/http"
require "uri"
require "json"
require "fileutils"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptService
        SCRIPT_SERVICE_URL = "https://script-service.shopifycloud.com"

        MOCK_ORG_ID = "100"
        DESCRIPTION_TEMPLATE = "Script '%s' created by CLI tool"
        DEPLOY_FAILED_MSG = "Deploy failed with status %{status} and message %{msg}"
        SCHEMA_FETCH_FAILED = "Failed to fetch schemas with status %{status} and message %{msg}"

        def fetch_extension_points
          response = Net::HTTP.get_response(fetch_uri)
          unless response.code.to_i == 200
            raise Domain::ServiceFailureError,
              format(SCHEMA_FETCH_FAILED, msg: response.msg, status: response.code)
          end
          JSON.parse(response.body)["result"]
        end

        def deploy(extension_point_type, extension_point_schema, script_name, bytecode, shop_id = nil)
          uri = deploy_uri
          request = Net::HTTP::Post.new(uri)
          request.set_form(build_form_data(
            shop_id,
            extension_point_type,
            extension_point_schema,
            script_name,
            bytecode
          ), "multipart/form-data")
          net_args = { use_ssl: uri.scheme == "https" }
          response = Net::HTTP.start(uri.hostname, uri.port, net_args) do |http|
            http.request(request)
          end
          raise Domain::ServiceFailureError, format(DEPLOY_FAILED_MSG, msg: response.msg, status: response.code) unless
            response.code.to_i == 200
        end

        private

        def build_form_data(shop_id, extension_point_type, extension_point_schema, script_name, bytecode)
          form = [
            ["org_id", org_id],
            ["extension_point_name", extension_point_type],
            ["source_code", bytecode],
            ["schema", extension_point_schema],
            ["title", script_name],
            ["description", get_description(script_name)],
          ]
          form.push(["shop_id", shop_id]) if shop_id
          form
        end

        def get_description(name)
          DESCRIPTION_TEMPLATE % name
        end

        def org_id
          MOCK_ORG_ID
        end

        def fetch_uri
          URI.parse("#{uri_base}/extension_points")
        end

        def deploy_uri
          URI.parse("#{uri_base}/deploy")
        end

        def uri_base
          (@_ ||= ENV["SCRIPT_SERVICE_URL"] || SCRIPT_SERVICE_URL).to_s
        end
      end
    end
  end
end
