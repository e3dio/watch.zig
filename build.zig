const std = @import("std");

pub fn build(b: *std.Build) !void {
    const name = "watch";

    const mod = b.createModule(.{
        .root_source_file = b.path(name ++ ".zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = mod,
    });
    
    b.installArtifact(exe);
}

