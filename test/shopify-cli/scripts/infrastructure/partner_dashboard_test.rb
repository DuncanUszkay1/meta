# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::PartnerDashboard do
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:partner_dashboard) { ShopifyCli::ScriptModule::Infrastructure::PartnerDashboard.new(ctx: ctx) }

  describe "authenticate" do
    subject { partner_dashboard.authenticate }

    it "should read PKCE token" do
      ShopifyCli::Helpers::PkceToken.expects(:read).with(ctx)
      subject
    end
  end
end
