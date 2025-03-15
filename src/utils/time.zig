const std = @import("std");

const Time = struct {
    years: u16 = 0,
    months: u4 = 0,
    days: u5 = 0,
    hours: u5 = 0,
    minutes: u6 = 0,
    secs: u7 = 0,
    millisecs: u10 = 0,

    pub fn fromMillisecs(timestamp_millisecs: u64) Time {
        const millisecs = timestamp_millisecs % std.time.ms_per_s;

        return .{
            .millisecs = @intCast(millisecs),
        };
    }

    pub fn fromSecs(timestamp_secs: u64) Time {
        return fromMillisecs(timestamp_secs * std.time.ms_per_s);
    }
};

test "time from millisecs" {
    const time0 = Time.fromMillisecs(0);
    const time1 = Time.fromMillisecs(4);
    const time2 = Time.fromMillisecs(1742048633345);
    try std.testing.expectEqualDeep(time0, Time{});
    try std.testing.expectEqualDeep(time1, Time{ .millisecs = 4 });
    try std.testing.expectEqualDeep(time2, Time{ .years = 2025, .months = 3, .days = 15, .hours = 14, .minutes = 23, .secs = 53, .millisecs = 345 });
}
