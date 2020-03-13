# frozen_string_literal: true

require "base64"
require "shopify_cli"
require "net/http"
require "uri"
require "json"
require "fileutils"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptService
        include SmartProperties

        DEPLOY_FAILED_MSG = "Deploy failed with status %{status} and message %{msg}"
        SCHEMA_FETCH_FAILED = "Failed to fetch schemas with status %{status} and message %{msg}"
        private_constant :DEPLOY_FAILED_MSG, :SCHEMA_FETCH_FAILED

        property! :ctx, accepts: ShopifyCli::Context

        def fetch_extension_points
          query = Helpers::PartnersAPI.load_query(ctx, "get_extension_points")
          proxy_request(query: query, api_key: nil)
        end

        def deploy(
          extension_point_type:,
          schema:,
          script_name:,
          script_content:,
          compiled_type:,
          api_key: nil,
          force: false
        )
          query_name = "app_script_update_or_create"
          query = Helpers::PartnersAPI.load_query(ctx, query_name)
          variables = {
            extensionPointName: extension_point_type.upcase,
            title: script_name,
            sourceCode: Base64.encode64(script_content),
            language: compiled_type,
            schema: schema,
            force: force,
          }
          resp_hash = proxy_request(query: query, api_key: api_key, variables: variables.to_json)
          user_errors = resp_hash["data"]["appScriptUpdateOrCreate"]["userErrors"]

          return resp_hash if user_errors.empty?

          if user_errors.any? { |e| e['tag'] == 'already_exists_error' }
            raise Infrastructure::ScriptRedeployError, api_key
          else
            raise Infrastructure::ScriptServiceUserError.new(query_name, user_errors.to_s, variables)
          end
        end

        def publish(api_key:, shop_id:, configuration:, extension_point_type:, title:)
          query_name = "shop_script_update_or_create"
          query = Helpers::PartnersAPI.load_query(ctx, query_name)
          variables = {
            extensionPointName: extension_point_type.upcase,
            configuration: configuration,
            title: title,
          }
          resp_hash = proxy_request(query: query, api_key: api_key, shop_id: shop_id, variables: variables.to_json)
          user_errors = resp_hash["data"]["shopScriptUpdateOrCreate"]["userErrors"]

          return resp_hash if user_errors.empty?

          if user_errors.any? { |e| e['tag'] == 'app_script_not_found' }
            raise Infrastructure::AppScriptUndefinedError, api_key
          else
            raise Infrastructure::ScriptServiceUserError.new(query_name, user_errors.to_s, variables)
          end
        end

        def unpublish(api_key:, shop_id:, extension_point_type:)
          query_name = "shop_script_delete"
          query = Helpers::PartnersAPI.load_query(ctx, query_name)
          variables = {
            extensionPointName: extension_point_type.upcase,
          }
          resp_hash = proxy_request(query: query, api_key: api_key, shop_id: shop_id, variables: variables.to_json)
          user_errors = resp_hash["data"]["shopScriptDelete"]["userErrors"]
          return resp_hash if user_errors.empty?

          if user_errors.any? { |e| e['tag'] == 'shop_script_not_found' }
            raise Infrastructure::ShopScriptUndefinedError, api_key
          else
            raise Infrastructure::ScriptServiceUserError.new(query_name, user_errors.to_s, variables)
          end
        end

        private

        def proxy_request(variables)
          query_name = "script_service_proxy"
          partners_resp = Helpers::PartnersAPI.query(ctx, query_name, **variables)
          raise_if_graphql_failed('Shopify Partners', query_name, partners_resp, variables)

          script_service_resp = JSON.parse(partners_resp['data']['scriptServiceProxy'])
          raise_if_graphql_failed('Script Service', query_name, script_service_resp, variables)

          script_service_resp
        end

        def raise_if_graphql_failed(from, query_name, response, variables)
          return unless response.key?('errors')
          if errors_has_code?(response['errors'], 'forbidden')
            raise Infrastructure::ForbiddenError
          elsif errors_has_code?(response['errors'], 'forbidden_on_shop')
            raise Infrastructure::ShopAuthenticationError
          elsif errors_has_code?(response['errors'], 'app_not_installed_on_shop')
            raise Infrastructure::AppNotInstalledError
          else
            raise Infrastructure::GraphqlError.new(from, query_name, response['errors'].to_s, variables)
          end
        end

        def errors_has_code?(errors, code)
          errors.any? { |e| e.dig('extensions', 'code') == code }
        end
      end
    end
  end
end
