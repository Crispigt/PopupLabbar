/// Author: Felix Stenberg
///
const std = @import("std");

pub fn readInput(allocator: std.mem.Allocator, reader: anytype) ![]u8 {
    return try reader.readToEndAlloc(allocator, std.math.maxInt(usize));
}

pub fn printResults(res: bool) !void {
    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    const writer = buffered.writer();
    if (res) {
        try writer.print("yes\n", .{});
    } else {
        try writer.print("no\n", .{});
    }

    try buffered.flush();
}

fn parseAndRunCombined(comptime T: type,data: []u8) !void {
    var splitter = std.mem.splitAny(u8, data, " \n");

    const n = try std.fmt.parseFloat(T,splitter.next().?);
    const M = try std.fmt.parseFloat(T, splitter.next().?);
    const q = try std.fmt.parseFloat(T, splitter.next().?);
    const s = try std.fmt.parseFloat(T, splitter.next().?);

    // n: number of nodes
    // m number of edges
    // q: queires
    // s: index of starting node

    // Then 
    // m lines of edges
    // u v with weight w 

    var m: usize = 0;
    while (m < M) : (m += 1) {
        const u = try parseNextToken([]const u8, &splitter);
        const v = try parseNextToken(u32, &splitter);
        const w = try parseNextToken(u32, &splitter);

        // Add to some data structure, maybe a neighbour mat or something in that manner

    }

    // Then q queries
    // need to understand format...


    std.debug.print("{d}\n", .{n});
}


/// Helper to parse the next token from the splitter.
fn parseNextToken(comptime T: type, splitter: anytype) !T {
    while (splitter.next()) |token| {
        if (token.len == 0) continue;
        return switch (T) {
            []const u8 => token,
            else => try std.fmt.parseInt(T, token, 10),
        };
    }
    return error.UnexpectedEndOfInput;
}


pub fn main() !void {
    const stdin = std.io.getStdIn();
    const allocator = std.heap.page_allocator;
    var buffer: [1024 * 1024]u8 = undefined;

    // const startRead = try Instant.now();
    const all_data = try readInput(
        allocator,
        stdin,
    );
    defer allocator.free(all_data);

    try parseAndRunCombined(all_data);

    // std.debug.print("this is res: \n", .{});
    // try printResults(testing);

    buffer[1] = '1';
}