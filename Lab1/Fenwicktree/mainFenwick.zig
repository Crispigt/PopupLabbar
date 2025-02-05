const std = @import("std");
const fenwick = @import("fenwickTree.zig");

const time = std.time;
const Instant = time.Instant;
const Timer = time.Timer;


pub fn main() !void {
    const stdin = std.io.getStdIn();
    const allocator = std.heap.page_allocator;
    var buffer: [1024*1024]u8 = undefined;


    // const startRead = try Instant.now();
    const all_data = try fenwick.readInput(allocator, stdin,);
    defer allocator.free(all_data);

    // const endRead = try Instant.now();
    
    // const startToFloat = try Instant.now();

    // // const arr = try unionF.parseTokens([]u8,allocator, all_data);
    // // defer allocator.free(arr); 

    // const endToFloat = try Instant.now();
 
    // const startCover = try Instant.now();
    // var start = try Instant.now();

    // var testing = try unionF.parseAndRunCombined(allocator,all_data );
    // defer allocator.free(testing);
    // try unionF.printResults(testing);


    // // const endCover = try Instant.now();

    // var end = try Instant.now();

    // const elapsed1: f64 = @floatFromInt(end.since(start));


    // const start = try Instant.now();

    const testing = try fenwick.parseAndRunCombinedArray(i64,allocator,all_data );
    //const testing = try unionF.parseAndRunCombinedArray(allocator,all_data );
    // std.debug.print("Does it break here", .{});
    defer allocator.free(testing);
    // std.debug.print("wtf", .{}); 16182.146ms
    // try unionF.printResults( testing);
    try fenwick.printResults(testing);


    // // const endCover = try Instant.now();

    // const end = try Instant.now();


    // std.debug.print("Time elapsed for parsing full is: {d:.3}ms\n", .{
    //     elapsed1 / time.ns_per_ms,
    // });

    // const elapsed2: f64 = @floatFromInt(end.since(start));
    // std.debug.print("Time elapsed for parsing full is: {d:.3}ms\n", .{
    //     elapsed2 / time.ns_per_ms,
    // });



    // const elapsedRead: f64 = @floatFromInt(endRead.since(startRead));
    // std.debug.print("Time elapsed for reading is: {d:.3}ms\n", .{
    //     elapsedRead / time.ns_per_ms,
    // });

    // const elapseFloat: f64 = @floatFromInt(endToFloat.since(startToFloat));
    // std.debug.print("Time elapsed for split is: {d:.3}ms\n", .{
    //     elapseFloat / time.ns_per_ms,
    // });


    // const elapsed2: f64 = @floatFromInt(endCover.since(startCover));
    // std.debug.print("Time elapsed for running algo is: {d:.3}ms\n", .{
    //     elapsed2 / time.ns_per_ms,
    // });


    buffer[1] = '1';
}   