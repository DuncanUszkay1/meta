# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Forms
    class PublishTest < MiniTest::Test
      include TestHelpers::Partners

      def test_use_provided_flags
        form = ask
        assert_equal(form.api_key, 'fakekey')
        assert_equal(form.shop_id, 1)
      end

      def test_raises_when_no_apps_available
        stub_organization
        assert_nil(ask(api_key: nil))
      end

      def test_pick_singular_app
        stub_organization(apps: [{ "apiKey" => 1234 }])
        Helpers::Organizations.stubs(:fetch_apps).returns([{ "apiKey" => 1234 }])
        form = ask(api_key: nil)
        assert_equal 1234, form.api_key
      end

      def test_display_selection_for_apps
        stub_organization(apps: [{ "apiKey" => 1234 }, { "apiKey" => 1267 }])
        CLI::UI::Prompt.expects(:ask)
          .with(
            'Which app do you want this script to belong to?'
          )
          .returns(1267)
        form = ask(api_key: nil)
        assert_equal(form.api_key, 1267)
      end

      def test_raises_when_no_shops_available
        stub_organization
        assert_nil(ask(shop_id: nil))
      end

      def test_pick_singular_shop
        stub_organization(stores: [{ 'shopId' => 1234 }])
        form = ask(shop_id: nil)
        assert_equal 1234, form.shop_id
      end

      def test_display_selection_for_shops
        stub_organization(stores: [{ 'shopId' => 1, 'shopDomain' => 'a' }, { 'shopId' => 2, 'shopDomain' => 'b' }])
        CLI::UI::Prompt.expects(:ask)
          .with('Select a development store.', options: %w(a b))
          .returns('a')
        form = ask(shop_id: nil)
        assert_equal(form.shop_id, 1)
      end

      private

      def stub_organization(apps: [], stores: [])
        Publish.any_instance.stubs(:organization).returns({ 'apps' => apps, 'stores' => stores })
      end

      def ask(api_key: 'fakekey', shop_id: 1)
        Publish.ask(
          @context,
          [],
          api_key: api_key,
          shop_id: shop_id
        )
      end
    end
  end
end
