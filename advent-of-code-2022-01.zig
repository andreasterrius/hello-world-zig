const std = @import("std");
const print = std.debug.print;

fn lessThan(context: void, a: u32, b: u32) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

// https://adventofcode.com/2022/day/1
// zig run advent-of-code-2022-01.zig
// CASE 1 AC, CASE 2 AC
pub fn main() !void {
    const file = try std.fs.cwd().openFile("advent-of-code-2022-01.input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    var currentSum: u32 = 0;
    var currentIndex: u32 = 0;

    var pq = std.PriorityQueue(u32, void, lessThan).init(std.heap.page_allocator, {});
    defer pq.deinit();

    while (try stream.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', 1024)) |line| {
        if (line.len == 0) {
            if (pq.len == 0) {
                try pq.add(currentSum);
            } else {
                var top = pq.peek().?;
                if (currentSum > top) {
                    try pq.add(currentSum);
                    if (pq.len > 3) {
                        _ = pq.remove();
                    }
                }
            }
            currentIndex += 1;
            currentSum = 0;
            continue;
        }
        var num = try std.fmt.parseInt(u32, line, 10);
        currentSum += num;
    }
    var top = pq.peek().?;
    if (currentSum > top) {
        try pq.add(currentSum);
        if (pq.len > 3) {
            _ = pq.remove();
        }
    }

    while (pq.len != 0) {
        var num = pq.peek().?;
        print("ANSWER: {any}\n", .{num});
        _ = pq.remove();
    }
}
