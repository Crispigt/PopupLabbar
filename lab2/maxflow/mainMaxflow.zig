/// Author: Felix Stenberg, Viktor Widin
///

const std = @import("std");
const maxflow = @import("maxflow.zig");

pub fn readInput(allocator: std.mem.Allocator, reader: anytype) ![]u8 {
    return try reader.readToEndAlloc(allocator, std.math.maxInt(usize));
}

fn parseAndRunCombined(allocator: std.mem.Allocator, comptime T: type, data: []u8) !void {
    var splitter = std.mem.splitAny(u8, data, " \n");

    const N = try std.fmt.parseInt(usize, splitter.next().?, 10);  // num nodes
    const M =  try std.fmt.parseInt(usize, splitter.next().?, 10); // edges
    const s =  try std.fmt.parseInt(usize, splitter.next().?, 10); // s is source
    const t =  try std.fmt.parseInt(usize, splitter.next().?, 10); // sink

    // n: number of nodes, 0 to n-1 
    // m number of edges

    const graph = try allocator.alloc(T, M*3);
    defer allocator.free(graph);
    @memset(graph, 0);
    // Then
    // m lines of edges
    // u v c, edge u to v, c capacity

    var m: usize = 0;
    while (m < M*3) : (m += 3) {
        const u = try std.fmt.parseInt(T, splitter.next().?, 10);
        const v = try std.fmt.parseInt(T, splitter.next().?, 10);
        const c = try std.fmt.parseInt(T, splitter.next().?, 10);
        graph[m] = u;
        graph[m+1] = v;
        graph[m+2] = c;
    }
    const res = try maxflow.max_flow(allocator, T, graph, N,s, t);
    defer allocator.free(res);
    const len = res.len;
    const countNodes = (len-1)/3;
    const flow = res[len-1];
    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    const writer = buffered.writer();

    try writer.print("{d} {d} {d}\n", .{N, flow, countNodes});
    var i: usize = 0;
    while (i < countNodes*3) : (i+=3) {
        try writer.print("{d} {d} {d}\n", .{res[i], res[i+1], res[i+2]});
    }
    try buffered.flush();

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

    try parseAndRunCombined(allocator,i32,all_data);

    buffer[1] = '1';
}



