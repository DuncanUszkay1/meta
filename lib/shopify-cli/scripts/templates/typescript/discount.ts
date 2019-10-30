import { Checkout, Discount, Discounts, LineItem } from "./types/discount";
import { Config } from "./configuration/configuration";

export function run(checkout: Checkout, config: Config): Discounts {
    return Discounts.fromArray(
        checkout.line_items.map<Discount>((line_item: LineItem) =>
            new Discount(line_item.id.toString(), 1000, "Extension Discount")
        )
    );
}
