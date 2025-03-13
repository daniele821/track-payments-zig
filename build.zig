const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "payments",
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    b.installArtifact(exe);

    // add a run step
    const run_step = b.step("run", "run the program");
    run_step.dependOn(b.getInstallStep());
    run_step.dependOn(&b.addRunArtifact(exe).step);

    // add a test step
    const test_step = b.step("test", "Run the tests");
    const tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
    });
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
