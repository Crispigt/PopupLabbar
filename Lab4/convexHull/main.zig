const std = @import("std");
const polyArea = @import("polyArea.zig");

fn parseAndRunCombinedArray(allocator: std.mem.Allocator, data: []u8) !void {
    
    var splitter = std.mem.splitAny(u8, data, " \n");

    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    const writer = buffered.writer();

    while (splitter.next()) |token| {
        if (std.mem.eql(u8,token, "") or std.mem.eql(u8,token, "0")) {
            continue;
        }

        const n = try std.fmt.parseInt(usize, token, 10);

        const points = try allocator.alloc(polyArea.point, n);


        for (0..n) |r| {

            const x = try std.fmt.parseFloat(f64, splitter.next().?);
            const y = try std.fmt.parseFloat(f64, splitter.next().?);
            points[r] = .{.x=x, .y=y };
        }

        const value = polyArea.polygon_area(points);



        if (value > 0) {
            try writer.print("CCW {d:.1}\n", .{value});        
        } else{
            try writer.print("CW {d:.1}\n", .{@abs(value)});
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

