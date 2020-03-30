# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class FormTest < MiniTest::Test
      def test_ask_api_key_aborts_if_no_apps
        assert_raises(ShopifyCli::Abort) do
          Helpers::Form.ask_app_api_key([])
        end
      end

      def test_ask_api_key_returns_api_key_if_only_one
        api_key = 'key'
        assert_equal api_key, Helpers::Form.ask_app_api_key([{ "apiKey" => api_key }])
      end

      def test_ask_api_key_prompts_api_key_if_multiple
        chosen_key = 'key'
        CLI::UI::Prompt.expects(:ask).returns(chosen_key)
        assert_equal chosen_key, Helpers::Form.ask_app_api_key([{ "apiKey" => chosen_key }, { "apiKey" => 'other' }])
      end

      def test_ask_org_aborts_if_no_org
        assert_raises(ShopifyCli::Abort) do
          Helpers::Form.ask_organization(@context, [])
        end
      end

      def test_ask_org_returns_org_if_only_one
        org = { "id" => 1, "businessName" => "name" }
        assert_equal org, Helpers::Form.ask_organization(@context, [org])
      end

      def test_ask_org_prompts_org_if_multiple
        chosen_id = 1
        chosen_org = { "id" => chosen_id, "businessName" => "name" }
        other_org = { "id" => chosen_id + 1, "businessName" => "another" }

        CLI::UI::Prompt.expects(:ask).returns(chosen_id)
        assert_equal chosen_org, Helpers::Form.ask_organization(@context, [chosen_org, other_org])
      end
    end
  end
end
