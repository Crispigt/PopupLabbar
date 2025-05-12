const std = @import("std");
const poly = @import("poly.zig");

fn parseAndRunCombinedArray(allocator: std.mem.Allocator, data: []u8) !void {
    
    var splitter = std.mem.splitAny(u8, data, " \n");

    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    const writer = buffered.writer();

    while (splitter.next()) |token| {
        if (std.mem.eql(u8,token, "") or std.mem.eql(u8,token, "0")) {
            continue;
        }
        // std.debug.print("\n new \n", .{});

        const n = try std.fmt.parseInt(usize, token, 10);
        // std.debug.print("n:{d} \n", .{n});
        const points = try allocator.alloc(poly.point, n);

        for (0..n) |r| {

            const x = try std.fmt.parseFloat(f64, splitter.next().?);
            const y = try std.fmt.parseFloat(f64, splitter.next().?);
            points[r] = .{.x=x, .y=y };
        }

        const n2 = try std.fmt.parseInt(usize, splitter.next().?, 10);
        // std.debug.print("n2:{d} \n", .{n2});
        const res = try allocator.alloc(i32, n2);
        for (0..n2) |value| {
            const x = try std.fmt.parseFloat(f64, splitter.next().?);
            const y = try std.fmt.parseFloat(f64, splitter.next().?);
            const o = poly.inside_poly(.{.x=x, .y=y }, points);
            res[value] = o;
        }
        // std.debug.print("\n res \n", .{});

        for (res) |value| {
            if (value == 1) {
                try writer.print("in\n", .{});        
            } else if (value == -1){
                try writer.print("out\n", .{});        
            } else {
                try writer.print("on\n", .{});        
            }
        }
    }
    
    try buffered.flush();
}



pub fn readInput(allocator: std.mem.Allocator, reader: anytype) ![]u8 {
    return try reader.readAllAlloc(allocator, std.math.maxInt(usize));
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const page_alloc = std.heap.page_allocator;

    var arena = std.heap.ArenaAllocator.init(page_alloc);
    defer arena.deinit();
    const aa = arena.allocator();

    const all_data = try readInput(page_alloc, stdin);
    defer page_alloc.free(all_data);

    try parseAndRunCombinedArray(aa, all_data);
}

