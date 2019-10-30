require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptService do
  subject { ShopifyCli::ScriptModule::Infrastructure::ScriptService.new }

  let(:response) { MiniTest::Mock.new }

  describe ".fetch_extension_points" do
    it "returns an array of available extension points" do
      response.expect(:code, 200)
      response.expect(:body, "{
        \"result\": [1, 2, 3]
      }")

      Net::HTTP.stub(:get_response, response) do
        assert_equal [1, 2, 3], subject.fetch_extension_points
      end
    end
  end
end
