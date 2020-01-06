require 'test_helper'

module ShopifyCli
  module Tasks
    class UpdateDashboardURLSTest < MiniTest::Test
      include TestHelpers::Partners

      def test_url_is_not_transformed_if_same
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '123', secret: 'foo'))
        api_key = '123'
        stub_partner_req(
          'get_app_urls',
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: 'https://123abc.ngrok.io',
                redirectUrlWhitelist: [
                  'https://123abc.ngrok.io',
                  'https://123abc.ngrok.io/callback/fake',
                ],
              },
            },
          },
        )
        ShopifyCli::Tasks::UpdateDashboardURLS.call(@context, url: 'https://123abc.ngrok.io')
      end

      def test_url_is_transformed_if_different_and_callback_is_appended
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '1234', secret: 'foo'))
        api_key = '1234'
        stub_partner_req(
          'get_app_urls',
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: 'https://newone123.ngrok.io',
                redirectUrlWhitelist: [
                  'https://123abc.ngrok.io',
                  'https://newone123.ngrok.io/callback/fake',
                ],
              },
            },
          },
        )

        stub_partner_req(
          'update_dashboard_urls',
          variables: {
            input: {
              applicationUrl: 'https://newone123.ngrok.io',
              redirectUrlWhitelist: ['https://newone123.ngrok.io', 'https://newone123.ngrok.io/callback/fake'],
              apiKey: api_key,
            },
          },
        )
        ShopifyCli::Tasks::UpdateDashboardURLS.call(@context, url: 'https://newone123.ngrok.io')
      end

      def test_only_ngrok_urls_are_updated
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '1234', secret: 'foo'))
        api_key = '1234'
        stub_partner_req(
          'get_app_urls',
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: 'https://newone123.ngrok.io',
                redirectUrlWhitelist: [
                  'https://123abc.ngrok.io',
                  'https://fake.fakeurl.com',
                  'https://fake.fakeurl.com/callback/fake',
                ],
              },
            },
          }
        )

        stub_partner_req(
          'update_dashboard_urls',
          variables: {
            input: {
              applicationUrl: 'https://newone123.ngrok.io',
              redirectUrlWhitelist: [
                'https://newone123.ngrok.io',
                'https://fake.fakeurl.com',
                'https://fake.fakeurl.com/callback/fake',
                'https://newone123.ngrok.io/callback/fake',
              ],
              apiKey: api_key,
            },
          }
        )
        ShopifyCli::Tasks::UpdateDashboardURLS.call(@context, url: 'https://newone123.ngrok.io')
      end

      def test_application_url_is_not_updated_if_user_says_no
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '1234', secret: 'foo'))
        api_key = '1234'
        stub_partner_req(
          'get_app_urls',
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: 'https://newone123.ngrok.io',
                redirectUrlWhitelist: [
                  'https://123abc.ngrok.io',
                  'https://fake.fakeurl.com',
                  'https://fake.fakeurl.com/callback/fake',
                ],
              },
            },
          }
        )

        stub_partner_req(
          'update_dashboard_urls',
          variables: {
            input: {
              applicationUrl: 'https://newone123.ngrok.io',
              redirectUrlWhitelist: [
                "https://123abc.ngrok.io",
                "https://fake.fakeurl.com",
                "https://fake.fakeurl.com/callback/fake",
                "https://myowndomain.io/callback/fake",
              ],
              apiKey: api_key,
            },
          }
        )
        CLI::UI::Prompt.expects(:confirm).returns(false)
        ShopifyCli::Tasks::UpdateDashboardURLS.call(@context, url: 'https://myowndomain.io')
      end
    end

    def test_application_url_is_updated_if_user_says_yes
      Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '1234', secret: 'foo'))
      api_key = '1234'
      stub_partner_req(
        'get_app_urls',
        variables: {
          apiKey: api_key,
        },
        resp: {
          data: {
            app: {
              applicationUrl: 'https://newone123.ngrok.io',
              redirectUrlWhitelist: [
                'https://123abc.ngrok.io',
                'https://fake.fakeurl.com',
                'https://fake.fakeurl.com/callback/fake',
              ],
            },
          },
        }
      )

      stub_partner_req(
        'update_dashboard_urls',
        variables: {
          input: {
            applicationUrl: 'https://myowndomain.io',
            redirectUrlWhitelist: [
              "https://myowndomain.io",
              "https://fake.fakeurl.com",
              "https://fake.fakeurl.com/callback/fake",
              "https://myowndomain.io/callback/fake",
            ],
            apiKey: api_key,
          },
        }
      )
      CLI::UI::Prompt.expects(:confirm).returns(true)
      ShopifyCli::Tasks::UpdateDashboardURLS.call(@context, url: 'https://myowndomain.io')
    end

    def test_whitelist_urls_are_updated_even_if_app_url_is_set
      Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '123', secret: 'foo'))
      api_key = '123'
      stub_partner_req(
        'get_app_urls',
        variables: {
          apiKey: api_key,
        },
        resp: {
          data: {
            app: {
              applicationUrl: 'https://newone123.ngrok.io',
              redirectUrlWhitelist: [],
            },
          },
        }
      )

      stub_partner_req(
        'update_dashboard_urls',
        variables: {
          input: {
            applicationUrl: 'https://newone123.ngrok.io',
            redirectUrlWhitelist: [
              'https://newone123.ngrok.io',
              'https://newone123.ngrok.io/callback/fake',
            ],
            apiKey: api_key,
          },
        }
      )
      ShopifyCli::Tasks::UpdateDashboardURLS.call(@context, url: 'https://newone123.ngrok.io')
    end

    def test_user_is_prompted_to_update_application_url
      Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '123', secret: 'foo'))
      api_key = '123'
      stub_partner_req(
        'get_app_urls',
        variables: {
          apiKey: api_key,
        },
        resp: {
          data: {
            app: {
              applicationUrl: 'https://123abc.ngrok.io',
              redirectUrlWhitelist: [
                'https://123abc.ngrok.io',
                'https://123abc.ngrok.io/callback/fake',
              ],
            },
          },
        },
      )
      CLI::UI::Prompt.expects(:confirm).returns(true)
      ShopifyCli::Tasks::UpdateDashboardURLS.call(@context, url: 'https://123adifferenturl.ngrok.io')
    end
  end
end
