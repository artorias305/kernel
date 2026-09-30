const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .abi = .none,
        .os_tag = .freestanding,
        .cpu_arch = .x86,
        .cpu_features_sub = std.Target.x86.featureSet(&.{ .sse, .sse2 }),
    });

    const kernel_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .red_zone = false,
    });

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_mod,
    });

    kernel.setLinkerScript(b.path("linker.ld"));

    b.installArtifact(kernel);

    const run_command = b.addSystemCommand(&.{ "qemu-system-i386", "-kernel" });
    run_command.addArtifactArg(kernel);
    if (b.args) |args| run_command.addArgs(args);

    const run_step = b.step("run", "Boot the kernel in QEMU");
    run_step.dependOn(&run_command.step);
}
