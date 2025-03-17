const std = @import("std");
const zdt = @import("zdt");

pub const DateUtil = struct {
    allocator: std.mem.Allocator,
    timezone: zdt.Timezone,

    pub fn init(allocator: std.mem.Allocator) !DateUtil {
        return .{
            .allocator = allocator,
            .timezone = try zdt.Timezone.tzLocal(allocator),
        };
    }
    pub fn deinit(self: *DateUtil) void {
        self.timezone.deinit();
    }
};

test "DateUtil init" {
    const allocator = std.testing.allocator;
    var date_unit = try DateUtil.init(allocator);
    defer date_unit.deinit();
}
