/// Author: Felix Stenberg
const std = @import("std");

/// A generic interval type parameterized by `T` (e.g., `i64`, `f64`, etc.).
/// The index field retains the original position from the input for reference.
pub fn Interval(comptime T: type) type {
    return struct {
        pub const Self = @This();

        start: T,
        end: T,
        index: usize,


        /// Sort primarily by `start` ascending; if tie, by `end` descending.
        pub fn lessThan(_: void, a: Self, b: Self) bool {
            if (a.start != b.start) {
                return a.start < b.start;
            }
            return a.end > b.end;
        }
    };
}

/// Finds a minimal subset of intervals that covers a interval interval.
/// Returns the indices of intervals used, in the sorted array.
///
/// Complexity: O(n log n) because of the sort.
///
/// Input: 
/// - T is ther numeric type for the interval boundaries (e.g. f64, i64). 
/// - allocator is the pointer on the heap for storing chosen subset.
/// - interval intervall to cover.
/// - interval_array Set of intervalls to cover interval with.
///
/// Output:
/// - Array of indecies into interval_array that cover interval.
/// - Empty slice if no solution exists.
pub fn cover(comptime T: type, allocator: std.mem.Allocator, interval: Interval(T).Self, interval_array: []Interval(T).Self) ![]usize {
    const IntervalType = Interval(T).Self;

    // Sort interval_array based on start (ascending) and end (descending)
    std.mem.sort(IntervalType, interval_array, {}, IntervalType.lessThan);

    if (interval.start > interval.end) {
        return &.{};
    }

    // Handle single-point interval interval
    if (interval.start == interval.end) {
        for (interval_array) |intervals| {
            if (intervals.start > interval.start) break;
            if (intervals.end >= interval.end) {
                const result = try allocator.alloc(usize, 1);
                result[0] = intervals.index;
                return result;
            }
        }
        return &.{};
    }

    var result = std.ArrayList(usize).init(allocator);
    errdefer result.deinit();

    var current_end = interval.start;
    var index: usize = 0;

    while (current_end < interval.end) {
        var best_end = current_end;
        var best_index: ?usize = null;

        // Find the farthest reaching interval starting before or at current_end
        while (index < interval_array.len and interval_array[index].start <= current_end) {
            if (interval_array[index].end > best_end) {
                best_end = interval_array[index].end;
                best_index = interval_array[index].index;
            }
            index += 1;
        }

        if (best_index == null) {
            return &.{};
        }

        try result.append(best_index.?);
        current_end = best_end;
    }

    return result.toOwnedSlice();
}


/// Helper function that converts either float or int to usize
fn toUsize(value: anytype) usize {
    return switch (@typeInfo(@TypeOf(value))) {
        .Float => @intFromFloat(value),
        .Int => @intCast(value),
        else => @compileError("Unsupported type for conversion to usize"),
    };
}

/// Parses input data and runs coverage tests.
/// Expects input format: [A B N ...intervals] for each test case.
pub fn parseAndRun(comptime T: type, input: []T, allocator: anytype) ![][]usize {
    var res = std.ArrayList([]usize).init(allocator);
    defer {
        for (res.items) |ress| allocator.free(ress);
        res.deinit();
    }

    const IntervalType = Interval(T);
    var count: usize = 0;
    while (count < input.len) {

        // Parse target interval
        const targetInterval = IntervalType{
            .start = input[count],
            .end = input[count+1],
            .index = count,
        };
        count +=2;

        // Parse number of intervals (must be integer)
        const num_intervals = toUsize(input[count]);
        count +=1;
        // Parse intervals
        var intervals = std.ArrayList(IntervalType).init(allocator);
        defer intervals.deinit();
        var i: usize = 0;
        while (i < num_intervals) : (i += 1) {
            const start_idx = count + (i * 2);
            try intervals.append(IntervalType{
                .start = input[start_idx],
                .end = input[start_idx + 1],
                .index = i,  // Index is just the loop counter
            });
        }
        count += num_intervals * 2;
        
        const testResult = try cover(T, allocator, targetInterval, intervals.items);
        try res.append(testResult);
    }
    return res.toOwnedSlice();
}

/// Prints coverage results in format asked for in Kattis.
pub fn printCoverage(result: [][]usize) !void {
    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    const writer = buffered.writer();
    for (result) |value| {
        if (value.len != 0) {
            try writer.print("{d}\n", .{value.len});
            for (value) |indecies| {
                try writer.print("{d} ", .{indecies});
            }
            try writer.print("\n", .{});
        } else {
            try writer.print("impossible\n", .{});
        }
    }
    try buffered.flush();
}

/// Reads entire input into a buffer without size restrictions.
pub fn readInput(allocator: std.mem.Allocator, reader: anytype) ![]u8 {
    return try reader.readToEndAlloc(allocator, std.math.maxInt(usize));
}

/// Parses input tokens into numeric values of type T.
pub fn parseTokens(comptime T: type, allocator: std.mem.Allocator, data: []const u8) ![]T {
    var tokens = std.ArrayList(T).init(allocator);
    var splitter = std.mem.splitAny(u8, data, " \n");
    while (splitter.next()) |token| {
        if (token.len == 0) continue;
        const value = try switch (T) {
            f64 => std.fmt.parseFloat(T, token),
            i64 => std.fmt.parseInt(T, token, 10),
            else => @compileError("Unsupported numeric type"),
        };
        try tokens.append(value);
    }
    return tokens.toOwnedSlice();
}