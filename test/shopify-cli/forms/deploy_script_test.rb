# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Forms
    class DeployScriptTest < MiniTest::Test
      include TestHelpers::Partners

      def test_use_provided_app
        form = ask(api_key: 'fakekey')
        assert_equal(form.api_key, 'fakekey')
      end

      def test_ask_calls_form_ask_app_api_key_when_no_flag
        apps = [{ "apiKey" => 1234 }]
        Helpers::Form.expects(:ask_app_api_key).with(apps)
        Helpers::Organizations.stubs(:fetch_with_app).with(@context).returns([{ "apps" => apps }])
        ask
      end

      private

      def ask(api_key: nil)
        DeployScript.ask(
          @context,
          [],
          api_key: api_key
        )
      end
    end
  end
end
