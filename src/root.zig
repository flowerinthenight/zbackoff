//! Backoff represents a struct for getting a jittered backoff value (nanoseconds) for operations
//! that needs to do sleeps with backoff between retries. The implementation is based on
//! https://www.awsarchitectureblog.com/2015/03/backoff.html.

const std = @import("std");

pub const Backoff = struct {
    /// The initial value of the retry period in ns, defaults to 1s.
    initial: u64 = 1e9,

    /// The max value of the retry period in ns, defaults to 30s.
    max: u64 = 30 * 1e9,

    /// The factor by which the retry period increases. It should be greater than 1, defaults to 2.
    multiplier: f64 = 2.0,

    last: u64 = 1e9, // internal, current retry period
    iter: u64 = 0,
    const Self = @This();

    /// Returns the next nanosecond duration that the caller should use to backoff.
    pub fn pause(self: *Self) u64 {
        self.iter = self.iter + 1;
        if (self.initial == 0) self.initial = 1e9;
        if (self.max == 0) self.max = 30 * 1e9;
        if (self.multiplier < 1.0) self.multiplier = 2.0;

        if (self.iter == 1) return self.initial;

        const mf = @as(f64, @floatFromInt(self.last)) * self.multiplier;
        const mu = @as(u64, @intFromFloat(mf));

        const seed = std.crypto.random.int(u64);
        var prng = std.rand.DefaultPrng.init(seed);
        const random = prng.random();
        const rval = 1 + random.uintAtMost(u64, mu);
        self.last = @min(self.max, rval);
        return self.last;
    }
};
