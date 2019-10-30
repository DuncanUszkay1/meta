# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::GraphQLTypeScriptBuilder do
  let(:builder) { ShopifyCli::ScriptModule::Infrastructure::GraphQLTypeScriptBuilder.new }
  describe ".build" do
    subject { builder.build(schema, "Do not change header") }

    describe "when schema consists of only input and output that is an array" do
      let(:schema) do
        "type Money {
          subunits: Int!
          iso_currency: String!
        }

        input MoneyInput {
          subunits: Int!
          iso_currency: String!
        }

        input MultiCurrencyRequest {
          money: MoneyInput!
          presentment_currency: String
          shop_currency: String
          discount: [Discount]
        }

        input Discount {
          value: Int!
        }

        type Query {
          run(root: MultiCurrencyRequest!): [Money!]
        }

        schema { query: Query }"
      end

      it "should generate the ts file with classes for input and helper plural output class encapsulating Slice" do
        expected_output =
          <<~HEREDOC
            /*
             Do not change header,
             */
            import { Slice, SliceUtf8 } from \"../shopify_runtime_types\";

            @unmanaged
            export class Moneys extends Slice<Money> {
              static fromArray(arr: Array<Money>): Moneys {
                return <Moneys>Slice.fromArray<Money>(arr);
              }
            }

            @unmanaged
            export class Money {
              public subunits: i32;
              public iso_currency: SliceUtf8;

              constructor(subunits: i32, iso_currency: String) {
                this.subunits = subunits;
                this.iso_currency = SliceUtf8.fromString(iso_currency);
              }
            }

            @unmanaged
            export class MultiCurrencyRequest {
              public money: MoneyInput;
              public presentment_currency: SliceUtf8;
              public shop_currency: SliceUtf8;
              public discount: Slice<Discount>;

              constructor(money: MoneyInput, presentment_currency: String, shop_currency: String, discount: Array<Discount>) {
                this.money = money;
                this.presentment_currency = SliceUtf8.fromString(presentment_currency);
                this.shop_currency = SliceUtf8.fromString(shop_currency);
                this.discount = Slice.fromArray<Discount>(discount);
              }
            }

            @unmanaged
            export class MoneyInput {
              public subunits: i32;
              public iso_currency: SliceUtf8;

              constructor(subunits: i32, iso_currency: String) {
                this.subunits = subunits;
                this.iso_currency = SliceUtf8.fromString(iso_currency);
              }
            }

            @unmanaged
            export class Discount {
              public value: i32;

              constructor(value: i32) {
                this.value = value;
              }
            }

            HEREDOC

        assert_equal expected_output, subject
      end
    end

    describe "when schema consists of both input and configuration" do
      let(:schema) do
        "type Query  {
          run(input: Checkout!, configuration: Configuration): [Discount!]!
        }

        type Discount {
          subunits: Int
        }

        input Checkout {
          line_items: [LineItem!]!
        }

        input Configuration {
          value: Int
        }

        input LineItem {
          id: String!
          quantity: Int!
          title: String!
        }
        "
      end

      it "should generate the ts file for containing both input and configuration classes" do
        expected_output =
          <<~HEREDOC
            /*
             Do not change header,
             */
            import { Slice, SliceUtf8 } from \"../shopify_runtime_types\";

            @unmanaged
            export class Discounts extends Slice<Discount> {
              static fromArray(arr: Array<Discount>): Discounts {
                return <Discounts>Slice.fromArray<Discount>(arr);
              }
            }

            @unmanaged
            export class Discount {
              public subunits: i32;

              constructor(subunits: i32) {
                this.subunits = subunits;
              }
            }

            @unmanaged
            export class Checkout {
              public line_items: Slice<LineItem>;

              constructor(line_items: Array<LineItem>) {
                this.line_items = Slice.fromArray<LineItem>(line_items);
              }
            }

            @unmanaged
            export class LineItem {
              public id: SliceUtf8;
              public quantity: i32;
              public title: SliceUtf8;

              constructor(id: String, quantity: i32, title: String) {
                this.id = SliceUtf8.fromString(id);
                this.quantity = quantity;
                this.title = SliceUtf8.fromString(title);
              }
            }

            @unmanaged
            export class Configuration {
              public value: i32;

              constructor(value: i32) {
                this.value = value;
              }
            }

          HEREDOC

        assert_equal expected_output, subject
      end
    end

    describe "when schema contains output that is not an array" do
      let(:schema) do
        "input Checkout {
          line_items: [LineItem!]!
        }

        input LineItem {
          titles: [String!]
        }

        type Discount {
          subunits: Int
        }

        type Query  {
          run(input: Checkout!): Discount!
        }
        "
      end

      it "should generate the ts file with correct classes " do
        expected_output =
          <<~HEREDOC
            /*
             Do not change header,
             */
            import { Slice, SliceUtf8 } from \"../shopify_runtime_types\";


            @unmanaged
            export class Discount {
              public subunits: i32;

              constructor(subunits: i32) {
                this.subunits = subunits;
              }
            }

            @unmanaged
            export class Checkout {
              public line_items: Slice<LineItem>;

              constructor(line_items: Array<LineItem>) {
                this.line_items = Slice.fromArray<LineItem>(line_items);
              }
            }

            @unmanaged
            export class LineItem {
              public titles: Slice<SliceUtf8>;

              constructor(titles: Array<String>) {
                this.titles = Slice.fromArray<SliceUtf8>(titles.map(x => SliceUtf8.fromString(x)));
              }
            }

          HEREDOC

        assert_equal expected_output, subject
      end
    end
  end
end
