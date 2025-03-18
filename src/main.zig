const std = @import("std");
const data = @import("./payments/data.zig");

const AllPayments = data.AllPayments;
const Order = data.Order;
const Payment = data.Payment;

pub fn main() !void {
    const ITER = 1_000_000;
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator = arena_allocator.allocator();

    for (0..5) |_| {
        var perf = std.time.nanoTimestamp();

        for (0..ITER) |_| {
            _ = try allocator.create(u128);
        }

        perf = std.time.nanoTimestamp() - perf;
        std.debug.print("SINGLE   = {}\n", .{perf});

        perf = std.time.nanoTimestamp();
        var arr = std.ArrayList(u128).init(allocator);

        for (0..ITER) |_| {
            _ = try arr.append(123);
        }

        perf = std.time.nanoTimestamp() - perf;
        std.debug.print("ARRAY    = {}\n", .{perf});

        perf = std.time.nanoTimestamp();
        arr.clearAndFree();

        try arr.appendNTimes(123, ITER);

        perf = std.time.nanoTimestamp() - perf;
        std.debug.print("ARRAY2   = {}\n", .{perf});

        const type1 = u8;
        const type2 = u12;
        var arr1 = std.ArrayList(type1).init(allocator);
        var arr2 = std.ArrayList(type2).init(allocator);

        for (0..ITER) |_| {
            try arr1.append(std.crypto.random.int(type1));
            try arr2.append(std.crypto.random.int(type2));
        }
        perf = std.time.nanoTimestamp();
        std.mem.sort(type1, arr1.items, {}, std.sort.asc(type1));
        perf = std.time.nanoTimestamp() - perf;
        std.debug.print("SORT8    = {}\n", .{perf});

        perf = std.time.nanoTimestamp();
        std.mem.sort(type2, arr2.items, {}, std.sort.asc(type2));
        perf = std.time.nanoTimestamp() - perf;
        std.debug.print("SORT128  = {}\n", .{perf});
        std.debug.print("-----------------\n", .{});
    }
}
