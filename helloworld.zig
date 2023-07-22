const std = @import("std");
const print = std.debug.print;

// zig run helloworld.zig
// Introduction to zig
pub fn main() void {
    print("Start Basic\n", .{});
    basics();
    print("______________________\n", .{});

    print("Start Arrays\n", .{});
    arrays();
    print("______________________\n", .{});

    print("Start Whiles\n", .{});
    loops();
    print("______________________\n", .{});

    print("Start Functions\n", .{});
    functions();
    print("______________________\n", .{});

    print("Start Errors\n", .{});
    errors();
    print("______________________\n", .{});

    print("Start Switch\n", .{});
    switchs();
    print("______________________\n", .{});

    print("Start Runtime Safety\n", .{});
    runtimeSafety();
    print("______________________\n", .{});

    print("Start Pointers\n", .{});
    pointers();
    print("______________________\n", .{});

    print("Start Slices\n", .{});
    slices();
    print("______________________\n", .{});

    print("Start Enums\n", .{});
    enums();
    print("______________________\n", .{});

    print("Start Structs\n", .{});
    structs();
    print("______________________\n", .{});

    print("Start Unions\n", .{});
    unions();
    print("______________________\n", .{});

    print("Start Integer Overflow\n", .{});
    integer_overflow();
    print("______________________\n", .{});

    print("Start Labelled Blocks\n", .{});
    labelled_blocks();
    print("______________________\n", .{});

    print("Start Optionals\n", .{});
    optionals();
    print("______________________\n", .{});

    print("Start Comptime\n", .{});
    comptimes();
    print("______________________\n", .{});
}

pub fn basics() void {
    //General flow
    print("Hello World!\n", .{});

    const amount = 32;
    print("I have {} dollars!\n", .{amount});

    if (amount + 10 == 42) {
        print("The answer is: {}! Type is : {}\n", .{ amount + 10, @TypeOf(amount) });
    }

    const ternary = if (amount == 32) true else false;
    print("Ternary: {}\n", .{ternary});
}

pub fn arrays() void {
    const arrs = [_]i32{ 1, 2, 3, 4, 5 };
    print("Array: {any}\n", .{arrs});
}

pub fn loops() void {
    var i: i32 = 0;
    print("while: ", .{});
    while (i < 10) : (i += 2) {
        print("{} ", .{i});
    }
    print("\n", .{});

    print("for: ", .{});
    const val = [_]u8{ 'a', 'b', 'c' };
    for (val, 0..) |char, index| {
        print("index {}: {c} ", .{ index, char });
    }
    print("\n", .{});
}

fn functions_addFive(x: u32) u32 {
    return x + 5;
}

pub fn functions() void {
    defer print("DEFER! This will be printed last\n", .{});

    const original = 10;
    const d = functions_addFive(original); // this doesnt mutate param
    print("original: {}, addFive: {}\n", .{ original, d });
}

const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{OutOfMemory};

pub fn failingFunction() error{ FileOpenError, AccessDenied }!void {
    return error.AccessDenied;
}

var problems: u32 = 98;
pub fn failingDeferFunction() error{ FileOpenError, AccessDenied, OutOfMemory }!void {
    errdefer problems += 1;
    try failingFunction();
}

pub fn errors() void {
    const err = FileOpenError.OutOfMemory;
    print("Error: {}\n", .{err});
    print("err == FileOpenError.OutOfMemory: {}\n", .{err == FileOpenError.OutOfMemory});

    const coerced_err: FileOpenError = AllocationError.OutOfMemory;
    print("coerced_err == FileOpenError.OutOfMemory: {}\n", .{coerced_err == FileOpenError.OutOfMemory});

    // error unions, very interesting
    const maybe_error: AllocationError!u16 = 10;
    const actually_error: AllocationError!u16 = AllocationError.OutOfMemory; //rust: Result<u16, AllocationError>
    const maybe_error_catch = maybe_error catch 0;
    const actually_error_catch = actually_error catch 20; //rust: unwrap_or

    print("maybe_error: {any}, actually_error: {any}\n", .{ maybe_error, actually_error });
    print("maybe_error_catch: {any}, actually_error: {any}\n", .{ maybe_error_catch, actually_error_catch });

    // call a failing function
    var func_err = failingFunction();
    print("func_err: {any}\n", .{func_err});

    failingFunction() catch |returned_err| {
        print("returned_err: {any}\n", .{returned_err});
    };

    failingDeferFunction() catch {};
    print("problems: {}\n", .{problems});
}

pub fn switchs() void {
    var x: i8 = 10;
    switch (x) { //statement
        -1...1 => {
            x = -x;
        },
        10, 100 => {
            x = @divExact(x, 10);
        },
        else => {},
    }
    print("x: {}\n", .{x});

    var y = switch (x) { //expression
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => 100,
    };
    print("y: {}\n", .{y});
}

pub fn runtimeSafety() void {
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = 5;
    //const b = a[index]; //panic if uncommented out
    //_ = b;

    @setRuntimeSafety(false);
    const c = a[index]; //not panic
    _ = c;

    @setRuntimeSafety(true);
    const d = 10; //change to any number != 10 to trigger unreachable
    const y: u32 = if (d == 10) 5 else unreachable;
    _ = y;
}

pub fn pointersIncrement(num: *u8) void {
    num.* += 1;
}

pub fn pointers() void {
    var x: u8 = 1;
    pointersIncrement(&x);

    //set to 0 == error
    //var zero: u16 = 0;
    //var y: *u8 = @intToPtr(*u8, zero);
    //_ = y;

    //const pointer
    const one: u8 = 1;
    var y = &one;
    //y.* += 1; //connt assign to constant
    print("pointer y: {}\n", .{y.*});
}

pub fn slices() void {
    const array = [_]u8{ 10, 20, 30, 40, 50 };
    const slice = array[1..3]; //can also use array[a..n]
    for (slice, 0..) |value, i| {
        print("index {}: {} ", .{ i, value });
    }
    print("\n", .{});
}

const Direction = enum { north, south, east, west };
const Value = enum(u2) { zero, one, two };
const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
    next, // million + 1
};
const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,
    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};
const Mode = enum {
    var count: u32 = 0;
    on,
    off,
};

pub fn enums() void {
    print("enum suits: {}\n", .{Suit.spades.isClubs()});
    print("enum million: {}\n", .{@enumToInt(Value2.next)});

    Mode.count += 10;
    print("mode.count +=1: {}\n", .{Mode.count});
}

const Vec3 = struct { x: f32, y: f32, z: f32, w: f32 = undefined };
const Stuff = struct {
    x: i32,
    y: i32,
    fn swap(self: *Stuff) void {
        const tmp = self.x;
        self.x = self.y;
        self.y = tmp;
    }
};

pub fn structs() void {
    const position = Vec3{ .x = 10.0, .y = 20.0, .z = 30.0 };
    print("{any}\n", .{position});

    var stuff = Stuff{ .x = 10, .y = 20 };
    stuff.swap();
    print("{any}\n", .{stuff});
}

const Result = union {
    int: i64,
    float: f64,
    bool: bool,
};

const Tag = enum { a, b, c };
const Tagged = union(Tag) { a: u8, b: f32, c: bool };

pub fn unions() void {
    var result = Result{ .int = 1234 };
    print("union int: {any}\n", .{result});
    // will return error if uncommented
    // how do we make union inactive ?
    // result.float = 12.34;
    // print("union float: {any}", .{result});

    var value = Tagged{ .a = 10 };
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* *= 2,
        .c => |*b| b.* = !b.*,
    }
    print("value: {any}\n", .{value});
}

pub fn integer_overflow() void {
    var a: u8 = 255;
    a +%= 1;
    print("integer overflow (wraparound): {}\n", .{a});

    const x: u64 = 200;
    const y = @intCast(u8, x);
    print("force cast u64->u8 (wraparound): {}\n", .{y});
}

pub fn labelled_blocks() void {
    var count: usize = 0;
    outer: for ([_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }) |_| {
        for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
            count += 1;
            continue :outer;
        }
    }

    var once: usize = 0;
    outer2: for ([_]i32{ 1, 2, 3 }) |_| {
        once += 1;
        break :outer2;
    }
    print("Once: {}\n", .{once});

    var end: u32 = 10;
    var number: u32 = 5;
    var i: u32 = 0;
    var k = while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
    print("k: {}\n", .{k});
}

pub fn optionals() void {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    var found = for (data, 0..) |v, i| {
        if (v == 5) break i;
    } else null;
    print("found: {any}\n", .{found});

    var a: ?f32 = null;
    var b = a orelse 0;
    print("unwrap optional: {any}\n", .{b});

    // panic if enabled
    // var c: ?f32 = null;
    // const d = c orelse unreachable;
    // const e = c.?;
    // print("d: {any}, e: {any}\n", .{ d, e });

    const num: ?i32 = 5;
    if (num != null) {
        const value = num.?;
        _ = value;
    }

    var num2: ?i32 = 5;
    if (num2) |*value| {
        value.* += 1;
    }
    print("payload capture (like rust if let: {any})\n", .{num2});
}

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

fn Matrix(
    comptime T: type,
    comptime width: comptime_int,
    comptime height: comptime_int,
) type {
    return [height][width]T;
}

fn addSmallInts(comptime T: type, a: T, b: T) T {
    return switch (@typeInfo(T)) {
        .ComptimeInt => a + b,
        .Int => |info| if (info.bits <= 16)
            a + b
        else
            @compileError("ints too large"),
        else => @compileError("only ints accepted"),
    };
}

fn GetBiggerInt(comptime T: type) type {
    return @Type(.{
        .Int = .{
            .bits = @typeInfo(T).Int.bits + 1,
            .signedness = @typeInfo(T).Int.signedness,
        },
    });
}

pub fn comptimes() void {
    var x = comptime fibonacci(10);
    print("comptime x: {}\n", .{x});

    var y = comptime blk: {
        break :blk fibonacci(10);
    };
    print("comptime y: {}\n", .{y});

    //branch on type
    const a = 5;
    const b: if (a < 10) f32 else i32 = 5;
    _ = b;

    const mat = Matrix(f32, 4, 4);
    print("comptime matrix: {any}\n", .{mat});

    const start = addSmallInts(u16, 20, 30);
    print("comptime addSmallInts: {any}\n", .{start});

    print("comptime getBiggerInt: {any}\n", .{GetBiggerInt(i8)});
}
