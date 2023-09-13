const std = @import("std");
const Self = @This();

const StaticMeshDescriptor = struct {
    resourcePath: []const u8
};

const SceneDescriptor = struct {
    staticMeshes : std.ArrayList(StaticMeshDescriptor),
};