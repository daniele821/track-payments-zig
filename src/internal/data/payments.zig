const std = @import("std");

pub const Payments = struct {
    allocator: std.mem.Allocator,
    strings_pool: StringPool,
    payments_pool: PaymentsPool,
    orders_pool: OrdersPool,
    cities: StringHashMap,
    shops: StringHashMap,
    methods: StringHashMap,
    items: StringHashMap,

    const Self = @This();
    const StringPool = std.ArrayListUnmanaged([]const u8);
    const PaymentsPool = std.ArrayListUnmanaged(Payment);
    const OrdersPool = std.ArrayListUnmanaged(std.ArrayListUnmanaged(Order));
    const StringHashMap = std.AutoHashMapUnmanaged(u32, void);

    const Order = struct {
        unit_price: u32,
        quantity: u32,
        item: u32,
    };

    const Payment = struct {
        city: u32,
        shop: u32,
        method: u32,
        date: i64,
        orders: u32,
    };

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .strings_pool = StringPool{},
            .payments_pool = PaymentsPool{},
            .orders_pool = OrdersPool{},
            .cities = StringHashMap{},
            .shops = StringHashMap{},
            .methods = StringHashMap{},
            .items = StringHashMap{},
        };
    }

    pub fn deinit(self: *Self) void {
        // test i can nest arryylist
        // if possible -> write loop to free OrdersPool inner lists
        self.strings_pool.deinit(self.allocator);
        self.payments_pool.deinit(self.allocator);
        self.orders_pool.deinit(self.allocator);
        self.cities.deinit(self.allocator);
        self.shops.deinit(self.allocator);
        self.methods.deinit(self.allocator);
        self.items.deinit(self.allocator);
    }
};

test "payments" {
    const allocator = std.testing.allocator;
    var payments = Payments.init(allocator);
    defer payments.deinit();
}
