const std = @import("std");
const raylib = @import("raylib");
const zphy = @import("zphysics");

const ObjectDescriptor = struct {
    resourcePath: []const u8,
    position: raylib.Vector3,
};

const SceneDescriptor = struct {
    const Self = @This();
    objectDescriptors: []ObjectDescriptor,
};

const Object = struct {
    model: raylib.Model,
    position: raylib.Vector3,
    physicsBodyId: ?zphy.BodyId,

    pub fn addPhysicsBody(self: *Object, bodyId: zphy.BodyId) void {
        self.physicsBodyId = bodyId;
    }
};

pub const Scene = struct {
    objects: std.ArrayList(Object),

    pub fn load(allocator: std.mem.Allocator, path: []const u8) !Scene {
        const data = try std.fs.cwd().readFileAlloc(allocator, path, 5120);
        defer allocator.free(data);

        const api = try std.json.parseFromSlice(SceneDescriptor, allocator, data, .{
            .ignore_unknown_fields = true,
        });
        defer api.deinit();

        var objects = try std.ArrayList(Object).initCapacity(allocator, api.value.objectDescriptors.len);
        for (api.value.objectDescriptors) |od| {
            var resourcePathC = try std.fmt.allocPrintZ(allocator, "{s}", .{od.resourcePath});
            defer allocator.free(resourcePathC);

            var model = raylib.LoadModel(resourcePathC);
            try objects.append(.{ .model = model, .position = od.position, .physicsBodyId = null });
        }

        return .{ .objects = objects };
    }

    pub fn deinit(self: @This()) void {
        for (self.objects.items) |obj| {
            raylib.UnloadModel(obj.model);
        }
        self.objects.deinit();
    }
};
