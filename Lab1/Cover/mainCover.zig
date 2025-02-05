/// Author: Felix Stenberg
const std = @import("std");
const cover = @import("intervalCover.zig");

const time = std.time;
const Instant = time.Instant;
const Timer = time.Timer;



pub fn main() !void {
    const stdin = std.io.getStdIn();
    const allocator = std.heap.page_allocator;
    var buffer: [1024*1024]u8 = undefined;

    // const start = try Instant.now();

    // const startRead = try Instant.now();
    // const input = try stdInput.readFullInputArrays(allocator, stdin.reader(), buffer[0..]);
    const all_data = try cover.readInput(allocator, stdin,);
    defer allocator.free(all_data);

    // const endRead = try Instant.now();
    
    // const startToFloat = try Instant.now();
    // var floatArray = try stdInput.delimiterStringToFloat32(input, " ", allocator);
    const floats_arr = try cover.parseTokens(f64,allocator, all_data);
    defer allocator.free(floats_arr); 

    // const endToFloat = try Instant.now();
 
    // const end = try Instant.now();

    // const startCover = try Instant.now();

    const testing = try cover.parseAndRun(f64,floats_arr, allocator);
    defer allocator.free(testing);
    try cover.printCoverage(testing);

    // std.debug.print("{any}\n", .{floats_arr});

    // const endCover = try Instant.now();



    // const elapsed1: f64 = @floatFromInt(end.since(start));
    // std.debug.print("Time elapsed for parsing full is: {d:.3}ms\n", .{
    //     elapsed1 / time.ns_per_ms,
    // });


    // const elapsedRead: f64 = @floatFromInt(endRead.since(startRead));
    // std.debug.print("Time elapsed for reading is: {d:.3}ms\n", .{
    //     elapsedRead / time.ns_per_ms,
    // });

    // const elapseFloat: f64 = @floatFromInt(endToFloat.since(startToFloat));
    // std.debug.print("Time elapsed for making it into full is: {d:.3}ms\n", .{
    //     elapseFloat / time.ns_per_ms,
    // });


    // const elapsed2: f64 = @floatFromInt(endCover.since(startCover));
    // std.debug.print("Time elapsed for running algo is: {d:.3}ms\n", .{
    //     elapsed2 / time.ns_per_ms,
    // });


    buffer[1] = '1';
}   