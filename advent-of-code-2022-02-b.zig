const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;

const ROCK: []const u8 = "A";
const PAPER: []const u8 = "B";
const SCISSOR: []const u8 = "C";

pub fn main() !void {
    //read file
    const file = try std.fs.cwd().openFile("advent-of-code-2022-02.input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    var mapping = std.StringHashMap([]const u8).init(std.heap.page_allocator);
    defer mapping.deinit();

    var score = std.StringHashMap(i32).init(std.heap.page_allocator);
    defer score.deinit();

    var sumScore: i32 = 0;

    //A = rock
    try mapping.put("XA", SCISSOR); //lose
    try mapping.put("YA", ROCK); //draw
    try mapping.put("ZA", PAPER); //win

    //B = PAPER
    try mapping.put("XB", ROCK); //lose
    try mapping.put("YB", PAPER); //draw
    try mapping.put("ZB", SCISSOR); //win

    // C = scissor
    try mapping.put("XC", PAPER); //lose
    try mapping.put("YC", SCISSOR); //draw
    try mapping.put("ZC", ROCK); //win

    try score.put(ROCK, 1); //rock
    try score.put(PAPER, 2); //paper
    try score.put(SCISSOR, 3); //scissor

    while (try stream.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', 1024)) |line| {
        var opponentOpt: ?[]const u8 = null;
        var mineOpt: ?[]const u8 = null;
        var it = std.mem.split(u8, line, " ");
        while (it.next()) |x| {
            if (opponentOpt == null) {
                opponentOpt = x;
            } else if (mineOpt == null) {
                mineOpt = x;
            } else break;
        }
        var opponent = opponentOpt orelse unreachable;
        var result = mineOpt orelse unreachable;
        var key = [2]u8{ result[0], opponent[0] };
        var mine = mapping.get(&key) orelse unreachable;

        print("{s}\n", .{mine});

        // check score we get
        if (eql(u8, mine, ROCK)) {
            sumScore += score.get(ROCK) orelse unreachable;
            if (eql(u8, opponent, SCISSOR)) {
                sumScore += 6;
            }
        } else if (eql(u8, mine, PAPER)) {
            sumScore += score.get(PAPER) orelse unreachable;
            if (eql(u8, opponent, ROCK)) {
                sumScore += 6;
            }
        } else if (eql(u8, mine, SCISSOR)) {
            sumScore += score.get(SCISSOR) orelse unreachable;
            if (eql(u8, opponent, PAPER)) {
                sumScore += 6;
            }
        }
        if (eql(u8, mine, opponent)) {
            sumScore += 3; //draw
        }

        //print("op: {?s}, mine: {?s}\n", .{ opponent, mine });
    }
    print("score: {}", .{sumScore});
}
