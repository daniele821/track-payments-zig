const std = @import("std");

// const StringSet = std.StringHashMap(void);

// const ValueSet = struct {
//     allPayments: *AllPayments,
//     cities: *StringSet,
//     shops: *StringSet,
//     methods: *StringSet,
//     items: *StringSet,
//
//     const Self = @This();
//
//     pub fn init(allPayments: *AllPayments) Self {
//         var cities = StringSet.init(allPayments.allocator);
//         var shop = StringSet.init(allPayments.allocator);
//         var methods = StringSet.init(allPayments.allocator);
//         var items = StringSet.init(allPayments.allocator);
//         return .{
//             .allPayments = allPayments,
//             .cities = &cities,
//             .shops = &shop,
//             .methods = &methods,
//             .items = &items,
//         };
//     }
//     pub fn deinit(self: *Self) void {
//         self.cities.deinit();
//         self.shops.deinit();
//         self.methods.deinit();
//         self.items.deinit();
//     }
// };

const AllPayments = struct {
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return Self{
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *AllPayments) void {
        _ = self;
    }
};

test "init" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer _ = allPayments.deinit();
}
