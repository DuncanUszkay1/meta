# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::ExtensionPoint do
  let(:id) { "id" }
  let(:schema) { "schema" }
  let(:type) { "discount" }

  describe ".new" do
    subject { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(id, type, schema) }
    it "should construct new ExtensionPoint" do
      assert_equal id, subject.id
      assert_equal schema, subject.schema
      assert_equal type, subject.type
    end
  end

  describe ".schema_file" do
    subject { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(id, type, schema).schema_file }
    it "should open schema file from id" do
      File.expects(:open).with(id)
      subject
    end
  end
end
