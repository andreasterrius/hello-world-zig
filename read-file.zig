const std = @import("std");
const mem = @import("std").mem;
const print = std.debug.print;

const SomeData = struct { value: i32, someBytes: [3]u8 };

// zig run read-file.zig
// Tries to write some bytes to file and read it back
pub fn main() !void {
    {
        //write the given data
        const file = try std.fs.cwd().createFile("read-file.txt", .{});
        defer file.close();

        var sd = SomeData{
            .value = 100,
            .someBytes = [_]u8{ 1, 2, 3 },
        };

        var bytesWritten = try file.write(mem.asBytes(&sd));
        print("bytesWritten: {}", .{bytesWritten});
    }

    {
        //read the data back
        const readFile = try std.fs.cwd().openFile("read-file.txt", .{});
        defer readFile.close();

        const allocator = std.heap.page_allocator;

        var bytesRead = try readFile.readToEndAlloc(allocator, 2048);
        print("bytesRead: {any}\n", .{bytesRead});

        var sd = mem.bytesAsSlice(SomeData, bytesRead);
        print("sd: {any}\n", .{sd});
    }
}
