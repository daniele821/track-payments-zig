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

    pub fn now(self: *DateUtil) !zdt.Datetime {
        const date = try zdt.Datetime.now(.{ .tz = &self.timezone });
        var fields = date.toFields();
        fields.tz_options = null;
        fields.nanosecond = 0;
        return try zdt.Datetime.fromFields(fields);
    }
};

test "DateUtil" {
    const allocator = std.testing.allocator;
    var date_unit = try DateUtil.init(allocator);
    defer date_unit.deinit();

    _ = try date_unit.now();
}
