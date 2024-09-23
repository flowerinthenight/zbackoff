[![Main](https://github.com/flowerinthenight/zbackoff/actions/workflows/main.yml/badge.svg)](https://github.com/flowerinthenight/zbackoff/actions/workflows/main.yml)

**zbackoff** implements jittered backoff. Useful when retrying operations that can potentially fail (i.e. network calls). The implementation is based on [this article](https://www.awsarchitectureblog.com/2015/03/backoff.html) from the AWS Architecture Blog.

You can use it like so:

``` zig
const std = @import("std");
const zbackoff = @import("zbackoff");

fn funcThatCanFail() !u64 {
    _ = try std.time.Instant.now();
    std.debug.print("funcThatFails()\n", .{});
    return error.UnwantedResult1;
}

pub fn main() void {
    var bo = zbackoff.Backoff{};
    for (0..3) |_| {
        const result = funcThatCanFail() catch {
            std.time.sleep(bo.pause());
            continue;
        };
        _ = result;
        break;
    }
}
```
