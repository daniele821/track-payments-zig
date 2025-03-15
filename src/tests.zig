const std = @import("std");

test {
    _ = @import("./main.zig");
    _ = @import("./utils/crypto.zig");
    _ = @import("./payments/data.zig");
}
