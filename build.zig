const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const fdt_lib = b.addStaticLibrary(.{
        .name = "libfdt",
        .target = target,
        .optimize = optimize,
    });
    fdt_lib.addIncludePath("libfdt");
    fdt_lib.linkLibC();

    fdt_lib.addCSourceFiles(&.{
        "libfdt/fdt.c",
        "libfdt/fdt_ro.c",
        "libfdt/fdt_wip.c",
        "libfdt/fdt_sw.c",
        "libfdt/fdt_rw.c",
        "libfdt/fdt_strerror.c",
        "libfdt/fdt_empty_tree.c",
        "libfdt/fdt_addresses.c",
        "libfdt/fdt_overlay.c",
        "libfdt/fdt_check.c",
    }, &.{
        // "-std=c++11",
        // "-fno-rtti",
        // "-fno-exceptions",
        // "-DHAVE_CONFIG_H",
        // "-D_SCL_SECURE_NO_WARNINGS",
        // "-D__STDC_LIMIT_MACROS",
        // "-D__STDC_CONSTANT_MACROS",
    });
    b.installArtifact(fdt_lib);

    // Generate files using flex(Assuming binary is installed in host pc)
    const flex_cmd = b.addSystemCommand(&[_][]const u8{
        "flex",
        "--outfile=dtc-lexer.lex.c",
        "dtc-lexer.l",
    });

    const bison_cmd = b.addSystemCommand(&[_][]const u8{
        "bison",
        "-d",
    });

    // DTC Binary
    const dtc = b.addExecutable(.{
        .name = "dtc",
        .target = target,
        .optimize = optimize,
    });
    dtc.linkLibC();
    dtc.linkLibrary(fdt_lib);
    dtc.addIncludePath("libfdt");

    dtc.addCSourceFiles(&.{
        "checks.c",
        "data.c",
        "dtc.c",
        "flattree.c",
        "fstree.c",
        "livetree.c",
        "srcpos.c",
        "treesource.c",
        "util.c",
        "dtc-lexer.lex.c",
        "dtc-parser.tab.c",
    }, &.{
        "-DNO_YAML",
    });
    dtc.step.dependOn(&flex_cmd.step);
    dtc.step.dependOn(&bison_cmd.step);
    b.installArtifact(dtc);
}
