const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const mem = std.mem;
const GRID_SIZE_X = 9;
const GRID_SIZE_Y = 9;

pub fn loadGridFromFile(path: []const u8) ![9][9]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();
    var grid: [GRID_SIZE_Y][GRID_SIZE_X]u8 = undefined;

    var rowIndex: u8 = 0;
    while (try stream.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', 1024)) |line| {
        if (rowIndex >= GRID_SIZE_Y) {
            print("rowIndex > GRID_SIZE_Y", .{});
            return error.GeneralError;
        }
        var it = std.mem.split(u8, line, " ");
        var columnIndex: u8 = 0;
        while (it.next()) |num| {
            if (columnIndex >= GRID_SIZE_X) {
                print("columnIndex > GRID_SIZE_X", .{});
                return error.GeneralError;
            }
            grid[rowIndex][columnIndex] = try std.fmt.parseInt(u8, num, 10);
            columnIndex += 1;
        }
        rowIndex += 1;
    }

    return grid;
}

pub fn getRowAvailableNumber(grid: [9][9]u8, row: u8) std.StaticBitSet(10) {
    var possibleValues = std.StaticBitSet(10).initFull();
    for (0..GRID_SIZE_X) |i| {
        if (grid[row][i] != 0) {
            possibleValues.setValue(grid[row][i], false);
        }
    }
    return possibleValues;
}

pub fn getColumnAvailableNumber(grid: [9][9]u8, column: u8) std.StaticBitSet(10) {
    var possibleValues = std.StaticBitSet(10).initFull();
    for (0..GRID_SIZE_Y) |i| {
        if (grid[i][column] != 0) {
            possibleValues.setValue(grid[i][column], false);
        }
    }
    return possibleValues;
}

// from the 3x3 cube that target is in, return the possible numbers
pub fn getZoneAvailableNumber(grid: [9][9]u8, targetRow: u8, targetColumn: u8) std.StaticBitSet(10) {
    var possibleValues = std.StaticBitSet(10).initFull();

    var zoneY = targetRow / 3;
    var zoneX = targetColumn / 3;
    for (0..3) |i| {
        for (0..3) |j| {
            var col = zoneX * 3 + i;
            var row = zoneY * 3 + j;
            if (grid[row][col] != 0) {
                possibleValues.setValue(grid[row][col], false);
            }
        }
    }

    return possibleValues;
}

pub fn solve(grid: *[9][9]u8, colP: u8, rowP: u8) !bool {
    var col: u8 = colP;
    var row: u8 = rowP;

    //print("({},{})\n", .{ row, col });
    //try debug(grid.*);

    while (grid[row][col] != 0) {
        col += 1;
        if (col >= 9) {
            col = 0;
            row += 1;
        }
        if (row >= 9) return true;
    }

    var possibleValue = getRowAvailableNumber(grid.*, row);
    possibleValue.setIntersection(getColumnAvailableNumber(grid.*, col));
    possibleValue.setIntersection(getZoneAvailableNumber(grid.*, row, col));

    for (1..10) |val| {
        if (possibleValue.isSet(val)) {
            grid[row][col] = @intCast(u8, val);
            var solved = try solve(grid, col, row);
            if (solved) {
                return true;
            }
        }
    }
    //print("backtrace\n", .{});
    grid[row][col] = 0;
    return false;
}

var debugFile: ?std.fs.File = null;
pub fn debug(grid: [9][9]u8) !void {
    if (debugFile == null) {
        //write the given data
        debugFile = try std.fs.cwd().createFile("sudoku-solution.txt", .{});
    }

    const string = try std.fmt.allocPrint(
        std.heap.page_allocator,
        "{any}\n{any}\n{any}\n{any}\n{any}\n{any}\n{any}\n{any}\n{any}\n\n",
        .{ grid[0], grid[1], grid[2], grid[3], grid[4], grid[5], grid[6], grid[7], grid[8] },
    );
    defer std.heap.page_allocator.free(string);
    _ = try (debugFile orelse unreachable).write(string);
}

pub fn main() !void {
    var grid = try loadGridFromFile("sudoku.txt");
    var hasSolution = try solve(&grid, 0, 0);

    if (hasSolution) {
        print("solution found, printing to sudoku-solution.txt!\n", .{});
        try debug(grid);
        if (debugFile != null) {
            (debugFile orelse unreachable).close();
        }
    } else {
        print("solution doesn't exist for this puzzle\n", .{});
    }

    // writeSolutionToFile("sudoku_solution.txt");
}

test "getRowAvailableNumber" {
    var grid: [9][9]u8 = undefined;
    grid[0] = [9]u8{ 1, 2, 0, 4, 5, 0, 7, 8, 0 };
    var possibleValues = getRowAvailableNumber(grid, 0);

    try expect(possibleValues.isSet(1) == false);
    try expect(possibleValues.isSet(2) == false);
    try expect(possibleValues.isSet(3) == true);
    try expect(possibleValues.isSet(4) == false);
    try expect(possibleValues.isSet(5) == false);
    try expect(possibleValues.isSet(6) == true);
    try expect(possibleValues.isSet(7) == false);
    try expect(possibleValues.isSet(8) == false);
    try expect(possibleValues.isSet(9) == true);
}

test "getColumnAvailableNumber" {
    var grid: [9][9]u8 = undefined;
    grid[0][0] = 1;
    grid[1][0] = 2;
    grid[2][0] = 3;
    grid[3][0] = 0;
    grid[4][0] = 9;
    grid[5][0] = 0;
    grid[6][0] = 0;
    grid[7][0] = 5;
    grid[8][0] = 0;
    var possibleValues = getColumnAvailableNumber(grid, 0);

    try expect(possibleValues.isSet(1) == false);
    try expect(possibleValues.isSet(2) == false);
    try expect(possibleValues.isSet(3) == false);
    try expect(possibleValues.isSet(4) == true);
    try expect(possibleValues.isSet(5) == false);
    try expect(possibleValues.isSet(6) == true);
    try expect(possibleValues.isSet(7) == true);
    try expect(possibleValues.isSet(8) == true);
    try expect(possibleValues.isSet(9) == false);
}

test "getZoneAvailableNumber" {
    var grid = [9][9]u8{
        [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        [_]u8{ 0, 0, 0, 0, 0, 0, 0, 1, 9 },
        [_]u8{ 0, 0, 0, 0, 0, 0, 0, 4, 3 },
        [_]u8{ 0, 0, 0, 0, 0, 0, 7, 5, 0 },
        [_]u8{ 2, 0, 0, 0, 0, 0, 0, 0, 0 },
        [_]u8{ 3, 1, 0, 0, 0, 0, 0, 0, 0 },
        [_]u8{ 0, 0, 9, 0, 0, 0, 0, 0, 0 },
    };

    var possibleValues = getZoneAvailableNumber(grid, 4, 7);
    try expect(possibleValues.isSet(1) == false);
    try expect(possibleValues.isSet(2) == true);
    try expect(possibleValues.isSet(3) == false);
    try expect(possibleValues.isSet(4) == false);
    try expect(possibleValues.isSet(5) == false);
    try expect(possibleValues.isSet(6) == true);
    try expect(possibleValues.isSet(7) == false);
    try expect(possibleValues.isSet(8) == true);
    try expect(possibleValues.isSet(9) == false);

    possibleValues = getZoneAvailableNumber(grid, 7, 0);
    try expect(possibleValues.isSet(1) == false);
    try expect(possibleValues.isSet(2) == false);
    try expect(possibleValues.isSet(3) == false);
    try expect(possibleValues.isSet(4) == true);
    try expect(possibleValues.isSet(5) == true);
    try expect(possibleValues.isSet(6) == true);
    try expect(possibleValues.isSet(7) == true);
    try expect(possibleValues.isSet(8) == true);
    try expect(possibleValues.isSet(9) == false);
}
