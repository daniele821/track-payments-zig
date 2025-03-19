const std = @import("std");

test {
    _ = @import("./main.zig");
    _ = @import("./internal/crypto.zig");
    _ = @import("./internal/date.zig");
    _ = @import("./internal/payments.zig");
    _ = @import("./internal/errors.zig");
}
