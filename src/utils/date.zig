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
        return zdt.Datetime.now(.{ .tz = &self.timezone });
    }

    pub fn unixToDatetime(unix_time: i64) !zdt.Datetime {
        return zdt.Datetime.fromUnix(unix_time, zdt.Duration.Resolution.second, null);
    }

    pub fn datetimeToUnix(date_time: zdt.Datetime) i64 {
        const unix_time = zdt.Datetime.toUnix(&date_time, zdt.Duration.Resolution.second);
        return @intCast(unix_time);
    }
};

test "DateUtil init" {
    const allocator = std.testing.allocator;
    var date_unit = try DateUtil.init(allocator);
    defer date_unit.deinit();
    _ = try date_unit.now();
}

test "DateUtil conversions" {
    const unix_time = 0;
    const date_time = try DateUtil.unixToDatetime(unix_time);
    const unix_time2 = DateUtil.datetimeToUnix(date_time);
    try std.testing.expectEqual(unix_time, unix_time2);
}
