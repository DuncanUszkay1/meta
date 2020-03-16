import * as %{extension_point_type} from "../src/%{extension_point_type}";
import { Slice, InternalTypes } from "@shopify/scripts-sdk-as";
import { run } from "../src/%{script_name}";

describe("run", () => {
  it("Should verify something", () => {
    expect<i32>(2).toBe(1, "Something is wrong");
  });
});
