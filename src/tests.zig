const std = @import("std");

test {
    _ = @import("./main.zig");
    _ = @import("./internal/utils/crypto.zig");
    _ = @import("./internal/utils/date.zig");
}
