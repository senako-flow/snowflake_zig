### Install

This library currently uses zig [0.17.0](https://ziglang.org/download/)

1. Run this command in your project folder to add `snowflake_zig` to your `build.zig.zon`

```bash
zig fetch --save git+https://github.com/senako-flow/snowflake_zig
```

2. Get the module in your `build.zig` file

```zig
const snowflake_dep = b.dependency("snowflake_zig", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("snowflake_zig", snowflake_dep.module("snowflake_zig"));
```

### Example

```zig
const std = @import("std");

const snowflake = @import("snowflake_zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    var node1 = snowflake.Node.init(io, 0, .default);
    var node2 = snowflake.Node.init(io, 1, .default);

    const id1 = try node1.generate();
    const id2 = try node1.generate();

    const id3 = try node2.generate();
    const id4 = try node2.generate();

    const id2_string = try id2.string(allocator);
    defer allocator.free(id2_string);

    const id4_string = try id4.string(allocator);
    defer allocator.free(id4_string);

    std.debug.print("node1 [id1]: {d}\n", .{id1.number()});
    std.debug.print("node1 [id2]: {s}\n", .{id2_string});

    std.debug.print("node2 [id3]: {d}\n", .{id3.number()});
    std.debug.print("node2 [id4]: {s}\n", .{id4_string});

    const opt = snowflake.Option{
        .sign = 0,
        .epoch = 1_704_067_200_000,
    };

    var node3 = snowflake.Node.init(io, 0, opt);
    var node4 = snowflake.Node.init(io, 1, opt);

    const id5 = try node3.generate();
    const id6 = try node3.generate();

    const id7 = try node4.generate();
    const id8 = try node4.generate();

    const id6_string = try id6.string(allocator);
    defer allocator.free(id6_string);

    const id8_string = try id8.string(allocator);
    defer allocator.free(id8_string);

    std.debug.print("node3 [id5]: {d}\n", .{id5.number()});
    std.debug.print("node3 [id6]: {s}\n", .{id6_string});

    std.debug.print("node4 [id7]: {d}\n", .{id7.number()});
    std.debug.print("node4 [id8]: {s}\n", .{id8_string});
}
```
