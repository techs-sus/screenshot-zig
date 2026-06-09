const std = @import("std");
const wio = @import("wio");
const Io = std.Io;

const default = @import("default");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    // std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    // const args = try init.minimal.args.toSlice(arena);
    // for (args) |arg| {
    //     std.log.info("arg: {s}", .{arg});
    // }

    try wio.init(arena, init.io, wio.EventQueue.eventFn, .{});
    defer wio.deinit();

    var events: wio.EventQueue = .empty;
    defer events.deinit();

    var window = try wio.Window.create(.{ .event_fn_data = &events });
    defer window.destroy();

    var framebuffer = try window.createFramebuffer(.{ .width = 1, .height = 1 });
    defer framebuffer.destroy();
    framebuffer.setPixel(0, 0, 0xF7A41D);

    while (true) {
        wio.update();
        while (events.pop()) |event| {
            switch (event) {
                .close => return,
                .draw => window.presentFramebuffer(&framebuffer),
                else => {},
            }
        }
    }
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
