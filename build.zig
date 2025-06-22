const std = @import("std");

pub fn build(b: *std.Build) !void {
    const name = "watch";

    const root = b.createModule(.{
        .root_source_file = b.path(name ++ ".zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    
    b.installArtifact(b.addExecutable(.{
        .name = name,
        .root_module = root,
    }));
}
