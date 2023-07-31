const std = @import("std");
const print = std.debug.print;

pub fn mutateAndPrint(single: []u8) void {
    single[0] = 10;
    for (single) |s| {
        print("{} ", .{s});
    }
    print("\n", .{});
}

pub fn mutateAndPrintMulti(multi: *[2][3]u8, rowP: u8, colP: u8) void {
    multi[0][0] = 10;
    var row = rowP;
    var col = colP;
    col += 1;
    for (multi) |m| {
        for (m) |ele| {
            print("{} ", .{ele});
        }
    }
    print("\n", .{});

    print("targeted: {}\n", .{multi[row][col]});
}

pub fn main() !void {
    //1d array testing
    var single = [_]u8{ 1, 2, 3, 4, 5 };
    mutateAndPrint(&single);

    var multi = [2][3]u8{
        [_]u8{ 1, 2, 3 },
        [_]u8{ 4, 5, 0 },
    };
    mutateAndPrintMulti(&multi, 1, 1);
}
