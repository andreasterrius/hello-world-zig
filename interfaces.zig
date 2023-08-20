const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

// turns out this struct is basically just a wrapper to a pointer
const Animal = struct {
    const Self = @This();

    ptr: *anyopaque,
    make_sound_fn: *const fn (ptr: *anyopaque) void,

    pub fn init(
        obj: anytype,
        comptime make_sound_fn: fn (ptr: @TypeOf(obj)) void,
    ) Animal {
        const Ptr = @TypeOf(obj);
        assert(@typeInfo(Ptr) == .Pointer); // Must be a pointer
        assert(@typeInfo(Ptr).Pointer.size == .One); // Must be a single-item pointer
        assert(@typeInfo(@typeInfo(Ptr).Pointer.child) == .Struct); // Must point to a struct
        const alignment = @typeInfo(Ptr).Pointer.alignment;
        _ = alignment;
        const impl = struct {
            fn make_sound(ptr: *anyopaque) void {
                const self = @as(Ptr, @ptrCast(@alignCast(ptr)));
                make_sound_fn(self);
            }
        };

        return .{
            .ptr = obj,
            .make_sound_fn = impl.make_sound,
        };
    }

    pub fn make_sound(self: Animal) void {
        self.make_sound_fn(self.ptr);
    }
};

const Dog = struct {
    const Self = @This();

    pub fn bark(self: *Dog) void {
        _ = self;
        print("woof woof\n", .{});
    }
};

const Cat = struct {
    const Self = @This();

    pub fn meow(self: *Cat) void {
        _ = self;
        print("meow meow\n", .{});
    }
};

pub fn check(animals: []Animal) void {
    for (animals) |a| {
        a.make_sound();
    }
}

pub fn main() !void {
    var dog = Dog{};
    var cat = Cat{};

    // this is quite similar (?) to unreal engine c++ event binding
    var animals = [_]Animal{
        Animal.init(&dog, Dog.bark),
        Animal.init(&cat, Cat.meow),
    };

    check(&animals);
}
