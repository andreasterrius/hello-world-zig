const std = @import("std");
const print = std.debug.print;
const raylib = @import("raylib");
const Self = @This();

const cameraDistance = raylib.Vector3{ .x = 3.0, .y = 4.0, .z = 6.0 };
const cameraLookAhead = raylib.Vector3{ .x = 0.0, .y = 0.0, .z = 6.0 };

// attributes
camera: raylib.Camera3D,
cameraTargetPosition: raylib.Vector3,

position: raylib.Vector3,

model: raylib.Model,

// input handling here
shouldMoveRight: f32,
shouldMoveForward: f32,
physicsSim: bool,

tryPick: bool,

pub fn init(position: raylib.Vector3, model: raylib.Model, shader: raylib.Shader) Self {
    model.materials.?[0].shader = shader;
    var cameraPosition = position.add(cameraDistance);
    return Self{
        .position = position,
        .model = model,
        .camera = .{
            // .position = .{ .x = 2.0, .y = 4.0, .z = 6.0 },
            .position = cameraPosition,
            .target = raylib.Vector3.zero(),
            .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
            .fovy = 45.0,
            .projection = .CAMERA_PERSPECTIVE,
        },
        .cameraTargetPosition = cameraPosition,
        .shouldMoveForward = 0.0, //[-1.0, 1.0]
        .shouldMoveRight = 0.0, //[1.0, 1.0]
        .physicsSim = false,
        .tryPick = false,
    };
}

pub fn deinit(self: Self) void {
    raylib.UnloadModel(self.model);
}

pub fn handleInput(self: *Self) void {
    self.shouldMoveForward = 0.0;
    self.shouldMoveRight = 0.0;

    if (raylib.IsKeyDown(.KEY_A)) {
        self.shouldMoveRight = -1.0;
    }
    if (raylib.IsKeyDown(.KEY_D)) {
        self.shouldMoveRight = 1.0;
    }
    if (raylib.IsKeyDown(.KEY_W)) {
        self.shouldMoveForward = 1.0;
    }
    if (raylib.IsKeyDown(.KEY_S)) {
        self.shouldMoveForward = -1.0;
    }
    if (raylib.IsKeyDown(.KEY_F)) {
        self.physicsSim = true;
    }
    if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
        self.tryPick = true;
    } else {
        self.tryPick = false;
    }
}

pub fn getCamera(self: Self) raylib.Camera3D {
    return self.camera;
}

pub fn updateCharacter(self: *Self, dt: f32) void {
    var speed: f32 = 5.0;
    self.position = raylib.Vector3{
        .x = self.position.x + (self.shouldMoveRight * dt * speed),
        .y = self.position.y,
        .z = self.position.z + (self.shouldMoveForward * dt * speed),
    };
}

pub fn updateCamera(self: *Self, dt: f32) void {
    //var cameraPosition = self.position.add(cameraDistance);
    var speed: f32 = 5.0;

    //hardcode this for now,
    var cameraPosition = self.*.camera.position;
    self.*.camera.position = raylib.Vector3{
        .x = cameraPosition.x + (self.shouldMoveRight * dt * speed),
        .y = cameraPosition.y,
        .z = cameraPosition.z + (self.shouldMoveForward * dt * speed),
    };
    //self.camera.target = self.position;
    //print("{any}, {any}\n", .{ self.camera.position, self.position });
}

pub fn useCamera(self: Self, shader: raylib.Shader) void {
    var cameraPos = [_]f32{
        self.camera.position.x,
        self.camera.position.y,
        self.camera.position.z,
    };
    raylib.SetShaderValue(shader, shader.locs.?[@intFromEnum(raylib.ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW)], &cameraPos, .SHADER_UNIFORM_VEC3);
}

// thirdPersonCamera(Camera) -> mutate the position and everything according to character pos and dir
pub fn render(self: Self) void {
    _ = self;
    //raylib.DrawModel(self.model, self.position, 1.0, raylib.WHITE);
}
