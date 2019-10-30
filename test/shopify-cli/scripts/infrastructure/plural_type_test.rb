require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::PluralType do
  describe ".new" do
    let(:string_wrapper) do
      <<~HEREDOC
        @unmanaged
        export class SliceUtf8s extends Slice<SliceUtf8> {
          static fromArray(arr: Array<SliceUtf8>): SliceUtf8s {
            return <SliceUtf8s>Slice.fromArray<SliceUtf8>(arr);
          }
        }
      HEREDOC
    end
    it "should construct and return proper fields" do
      line_item_array_type = ShopifyCli::ScriptModule::Infrastructure::PluralType.new("[LineItem!]", "foo", "Slice<LineItem>")
      assert_equal "Array<LineItem>", line_item_array_type.constructor_type
      assert_equal "Slice.fromArray<LineItem>(foo)", line_item_array_type.assignment_rhs_type

      string_slice_type = ShopifyCli::ScriptModule::Infrastructure::PluralType.new("[String!]", "foo", "Slice<SliceUtf8>")
      assert_equal "Array<String>", string_slice_type.constructor_type
      assert_equal "Slice.fromArray<SliceUtf8>(foo.map(x => SliceUtf8.fromString(x)))", string_slice_type.assignment_rhs_type
      assert_equal string_wrapper, string_slice_type.wrapper
    end
  end
end
