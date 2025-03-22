const std = @import("std");

test {
    _ = @import("./main.zig");
    _ = @import("./internal/utils/crypto.zig");
    _ = @import("./internal/utils/date.zig");
    _ = @import("./internal/data/payments.zig");
    _ = @import("./internal/data/payments_basic.zig");
    _ = @import("./internal/data/payments_optimized.zig");
}
