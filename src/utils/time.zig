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
        const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(millisecs / 1000) };
        const epoch_day = epoch_seconds.getEpochDay();
        const day_seconds = epoch_seconds.getDaySeconds();
        const year_day = epoch_day.calculateYearDay();
        const month = year_day.calculateMonthDay();
        const hours = day_seconds.getHoursIntoDay();
        const minutes = day_seconds.getMinutesIntoHour();
        const seconds = day_seconds.getSecondsIntoMinute();

        return .{
            .years = year_day.year,
            .months = month.month.numeric(),
            .days = month.day_index + 1,
            .hours = hours,
            .minutes = minutes,
            .secs = seconds,
            .millisecs = @intCast(millisecs),
        };
    }

    pub fn fromSecs(timestamp_secs: u64) Time {
        return fromMillisecs(timestamp_secs * std.time.ms_per_s);
    }
};

test "time from millisecs" {
    const time0 = Time.fromMillisecs(0);
    const time1 = Time.fromMillisecs(1742048633345);
    std.debug.print("{}\n", .{time0});
    std.debug.print("{}\n", .{time1});
    try std.testing.expectEqualDeep(Time{ .years = 1970, .months = 1, .days = 1 }, time0);
    try std.testing.expectEqualDeep(Time{ .years = 2025, .months = 3, .days = 15, .hours = 14, .minutes = 23, .secs = 53, .millisecs = 345 }, time1);
}
