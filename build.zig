const std = @import("std");

pub fn build(b: *std.Build) !void {
    const name = "watch";

    const t = b.standardTargetOptions(.{});
    const o = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .target = t,
        .optimize = o,
        .root_source_file = b.path(name ++ ".zig"),
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = mod,
    });
    
    b.installArtifact(exe);
}

