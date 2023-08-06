const std = @import("std");
const raylib = @import("raylib");

const Tic = enum {
    X,
    O,
    Empty,
};

pub fn winCheck(state: [3][3]Tic) Tic {
    for (0..3) |i| {
        if (state[0][i] != Tic.Empty and state[0][i] == state[1][i] and state[1][i] == state[2][i]) {
            return state[0][i];
        }
        if (state[i][0] != Tic.Empty and state[i][0] == state[i][1] and state[i][1] == state[i][2]) {
            return state[i][0];
        }
    }

    if (state[0][0] != Tic.Empty and state[0][0] == state[1][1] and state[1][1] == state[2][2]) {
        return state[0][0];
    }
    if (state[0][2] != Tic.Empty and state[0][2] == state[1][1] and state[1][1] == state[2][0]) {
        return state[0][2];
    }
    return Tic.Empty;
}

pub fn drawCheck(state: [3][3]Tic) bool {
    var count: i32 = 0;
    for (state) |row| {
        for (row) |cell| {
            if (cell != Tic.Empty) {
                count += 1;
            }
        }
    }
    if (count == 9) {
        return true;
    }

    return false;
}

pub fn reset(state: *[3][3]Tic) void {
    state.* = [3][3]Tic{
        [3]Tic{ Tic.Empty, Tic.Empty, Tic.Empty },
        [3]Tic{ Tic.Empty, Tic.Empty, Tic.Empty },
        [3]Tic{ Tic.Empty, Tic.Empty, Tic.Empty },
    };
}

pub fn main() !void {
    raylib.InitWindow(600, 620, "Tic Tac Toe");
    defer raylib.CloseWindow();

    raylib.SetConfigFlags(.{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(60);

    var state = [3][3]Tic{
        [3]Tic{ Tic.Empty, Tic.Empty, Tic.Empty },
        [3]Tic{ Tic.Empty, Tic.Empty, Tic.Empty },
        [3]Tic{ Tic.Empty, Tic.Empty, Tic.Empty },
    };
    var xWin: i32 = 0;
    var oWin: i32 = 0;
    var draw: i32 = 0;

    var whoseTurn = Tic.X;

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.DrawLine(200, 0, 200, 600, raylib.WHITE);
        raylib.DrawLine(400, 0, 400, 600, raylib.WHITE);
        raylib.DrawLine(0, 200, 600, 200, raylib.WHITE);
        raylib.DrawLine(0, 400, 600, 400, raylib.WHITE);
        raylib.DrawLine(0, 600, 600, 600, raylib.WHITE);

        // handle input
        var isMouseDown = raylib.IsMouseButtonPressed(raylib.MouseButton.MOUSE_BUTTON_LEFT);
        if (isMouseDown) {
            var mousePos = raylib.GetMousePosition();
            var column = @as(usize, @intFromFloat(mousePos.x / 200));
            var row = @as(usize, @intFromFloat(mousePos.y / 200));
            if (state[row][column] == Tic.Empty) {
                state[row][column] = whoseTurn;
                if (whoseTurn == Tic.X) {
                    whoseTurn = Tic.O;
                } else if (whoseTurn == Tic.O) {
                    whoseTurn = Tic.X;
                }

                var winTic = winCheck(state);
                if (winTic == Tic.O) {
                    oWin += 1;
                    reset(&state);
                } else if (winTic == Tic.X) {
                    xWin += 1;
                    reset(&state);
                }
                if (drawCheck(state)) {
                    draw += 1;
                    reset(&state);
                }
            }
        }
        // make it look better
        const renderOffsetX = 43;
        const renderOffsetY = 13;

        var drawTextBuf = [_]u8{0} ** 50;
        var xWinTextBuf = [_]u8{0} ** 50;
        var oWinTextBuf = [_]u8{0} ** 50;
        var drawText = try std.fmt.bufPrintZ(&drawTextBuf, "Draw: {}", .{draw});
        var xWinText = try std.fmt.bufPrintZ(&xWinTextBuf, "X Win: {}", .{xWin});
        var oWinText = try std.fmt.bufPrintZ(&oWinTextBuf, "O Win: {}", .{oWin});

        raylib.DrawText(drawText, 0, 600, 20, raylib.WHITE);
        raylib.DrawText(xWinText, 240, 600, 20, raylib.RED);
        raylib.DrawText(oWinText, 500, 600, 20, raylib.GREEN);

        // render tic tac toe grid
        for (state, 0..) |row, j| {
            for (row, 0..) |cell, i| {
                var coordX = @as(i32, @intCast(i * 200)) + renderOffsetX;
                var coordY = @as(i32, @intCast(j * 200)) + renderOffsetY;
                if (cell == Tic.O) {
                    raylib.DrawText("O", coordX, coordY, 200, raylib.GREEN);
                } else if (cell == Tic.X) {
                    raylib.DrawText("X", coordX, coordY, 200, raylib.RED);
                }
            }
        }

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);
    }
}
