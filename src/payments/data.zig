const std = @import("std");

const StringSet = std.StringHashMap(void);
const String = []const u8;

const ValueSet = struct {
    allocator: std.mem.Allocator,
    cities: StringSet,
    shops: StringSet,
    methods: StringSet,
    items: StringSet,

    pub fn init(allocator: std.mem.Allocator) ValueSet {
        return .{
            .allocator = allocator,
            .cities = StringSet.init(allocator),
            .shops = StringSet.init(allocator),
            .methods = StringSet.init(allocator),
            .items = StringSet.init(allocator),
        };
    }
    pub fn deinit(self: *ValueSet) void {
        self.cities.deinit();
        self.shops.deinit();
        self.methods.deinit();
        self.items.deinit();
    }
};

// const Order = struct {
//     quantity: u32,
//     unit_price: u32,
//     item: String,
// };

const AllPayments = struct {
    allocator: std.mem.Allocator,
    value_set: ValueSet,

    pub fn init(allocator: std.mem.Allocator) AllPayments {
        return .{
            .allocator = allocator,
            .value_set = ValueSet.init(allocator),
        };
    }
    pub fn deinit(self: *AllPayments) void {
        self.value_set.deinit();
    }
};

test "init" {
    const allocator = std.testing.allocator;
    var allPayments = AllPayments.init(allocator);
    defer _ = allPayments.deinit();
}
