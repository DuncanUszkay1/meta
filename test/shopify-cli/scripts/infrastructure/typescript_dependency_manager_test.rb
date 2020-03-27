# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager do
  include TestHelpers::FakeFS

  let(:script_name) { "foo_discount_script" }
  let(:language) { "ts" }
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:ts_dep_manager) do
    ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager.new(ctx, script_name, language)
  end

  describe ".bootstrap" do
    subject { ts_dep_manager.bootstrap }

    it "should write to npmrc" do
      subject
      assert File.exist?(".npmrc")
    end

    it "should write to package.json" do
      subject
      assert File.exist?("package.json")
    end
  end

  describe ".installed?" do
    subject { ts_dep_manager.installed? }

    it "should return true if node_modules folder exists" do
      FileUtils.mkdir_p("node_modules")
      assert_equal true, subject
    end

    it "should return false if node_modules folder does not exists" do
      assert_equal false, subject
    end
  end

  describe ".install" do
    subject { ts_dep_manager.install }

    it "should install using npm" do
      ctx.expects(:capture2e)
        .with("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
        .returns([nil, mock(success?: true)])
      subject
    end

    it "should raise error on failure" do
      msg = 'error message'
      ctx.expects(:capture2e).returns([msg, mock(success?: false)])
      assert_raises ShopifyCli::ScriptModule::Infrastructure::DependencyInstallError, msg do
        subject
      end
    end
  end
end
