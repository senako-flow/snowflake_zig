const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("snowflake_zig", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/snowflake_zig.zig"),
    });
}
