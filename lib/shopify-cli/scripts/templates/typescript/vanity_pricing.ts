import { Slice, SliceUtf8 } from "./shopify_runtime_types";
import { MultiCurrencyRequest, Money } from "./types/vanity_pricing";
import { Config } from "./configuration/configuration";

export function run(req: MultiCurrencyRequest, config: Config): Money {
    if (req.money.subunits % 10 >= 5) {
        return new Money(req.money.subunits + 10 - req.money.subunits % 10, req.money.iso_currency);
    } else {
        return new Money(req.money.subunits - req.money.subunits % 10, req.money.iso_currency);
    }
}

