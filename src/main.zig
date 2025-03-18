const std = @import("std");
const data = @import("./payments/data.zig");

const AllPayments = data.AllPayments;
const Order = data.Order;
const Payment = data.Payment;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var allPayments = AllPayments.init(allocator);
    defer allPayments.deinit();
    try allPayments.addValues(&.{"City"}, &.{"Shop"}, &.{"Method"}, &.{ "Item1", "Item2", "Item3" });
    const order1 = try Order.init(allPayments.value_set, 3, 129, "Item1");
    const order2 = try Order.init(allPayments.value_set, 4, 100, "Item2");
    const order3 = try Order.init(allPayments.value_set, 1, 342, "Item3");

    const TOT: usize = 10_000_000;
    var pay = try Payment.init(allocator, allPayments.value_set, "City", "Shop", "Method", 0);
    for (0..TOT) |value| {
        pay.date = @intCast(value);
        const pay_ptr = try allPayments.addPayment(pay);
        _ = try allPayments.addOrder(pay_ptr, order1);
        _ = try allPayments.addOrder(pay_ptr, order3);
        _ = try allPayments.addOrder(pay_ptr, order2);
    }

    for (allPayments.payments.items, 0..) |payment, index_payment| {
        if (index_payment == 0) continue;
        try std.testing.expect(allPayments.payments.items[index_payment - 1].lessThen(payment));
        for (payment.orders.items, 0..) |order, index_order| {
            if (index_order == 0) continue;
            try std.testing.expect(payment.orders.items[index_order - 1].lessThen(order));
        }
    }
}
