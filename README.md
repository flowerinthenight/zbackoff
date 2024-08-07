[![Main](https://github.com/flowerinthenight/zbackoff/actions/workflows/main.yml/badge.svg)](https://github.com/flowerinthenight/zbackoff/actions/workflows/main.yml)

**Backoff** implements jittered backoff. The implementation is based on https://www.awsarchitectureblog.com/2015/03/backoff.html.

You can use it like so:

``` zig
const std = @import("std");
const zbackoff = @import("zbackoff");

fn funcThatCanFail() !u64 {
  _ = try std.time.Instant.now();
  return 1;
}

pub fn main() void {
  var bo = zbackoff.Backoff{};
  for (0..3) |_| {
    const ret = funcThatCanFail();
    if (ret != 0) {
      std.time.sleep(bo.pause());
    }
  }
}
```
