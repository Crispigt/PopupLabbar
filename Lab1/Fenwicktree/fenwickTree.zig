/// Author: Felix Stenberg
const std = @import("std");



/// Constructs a Fenwick Tree (Binary Indexed Tree) for a given type `T`.
/// 
/// /// Parameters:
/// - `comptime T`: The type of elements stored in the tree (e.g., `i32`, `i64`).
///
/// Returns:
/// - A type representing the Fenwick Tree, with methods for initialization, updates, and queries.
pub fn FennWick(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        bittree: []T,

        /// Initializes a Fenwick Tree with a given size.
        /// 
        /// Parameters:
        /// - `allocator`: Zig memory allocator (e.g., std.heap.page_allocator).
        /// - `size`: Number of elements in the underlying array (0-based).
        /// 
        /// Returns:
        /// - A Fenwick Tree instance with all elements initialized to zero.
        /// - Errors: Allocation failures (e.g., out-of-memory).
        pub fn init(allocator: std.mem.Allocator, size: usize) !Self {
            const bittree = try allocator.alloc(T, size + 1);
            for (bittree) |*bit| {
                bit.* = 0;
            }
            return Self{
                .allocator = allocator,
                .bittree = bittree,
            };
        }

        /// De-initializes the Fennwick tree structure, freeing allocated memory.
        ///
        /// This must be called when the Fennwick tree is no longer needed to
        /// avoid memory leaks.
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.bittree);
        }

        /// Adds a value to the element at a 0-based index.
        /// 
        /// Parameters:
        /// - `index`: 0-based index of the element to update.
        /// - `number`: Value to add to the element.
        pub fn add(self: *Self, index: usize, number: T) void {
            var indx = index + 1; // One indexed
            
            // Add to all parent nodes
            while (indx < self.bittree.len) {
                self.bittree[indx] += number;
                // This changes the least signigicant bit, kinda like moving up one power of two, which will be the parent
                indx += indx & -%indx;
            }
        }
        
        /// Computes the prefix sum up to a 1-based index (inclusive).
        /// 
        /// Parameters:
        /// - `index`: 1-based index up to which the sum is calculated.
        /// 
        /// Returns:
        /// - Sum of elements from the first element (1-based) up to `index`.
        pub fn sum(self: *Self, index: usize) T {
            var summation: T = 0;
            var indx = index;

            // Add from index and all parents
            while (indx > 0) {
                summation += self.bittree[indx];
                indx -= indx & -%indx;
            }

            return summation;
        }
    };
}

/// Reads entire input into a buffer without size restrictions.
pub fn readInput(allocator: std.mem.Allocator, reader: anytype) ![]u8 {
    return try reader.readToEndAlloc(allocator, std.math.maxInt(usize));
}

/// Parse, set up based on input from kattis, and then run the fennwick algo 
pub fn parseAndRunCombinedArray(comptime T: type, allocator: std.mem.Allocator, data: []const u8) ![]T {
    var splitter = std.mem.splitAny(u8, data, " \n");

    const N = try parseNextToken(usize, &splitter);
    const Q = try parseNextToken(usize, &splitter);

    var fennwick = try FennWick(T).init(allocator, N);
    defer fennwick.deinit();

    var result = std.ArrayList(T).init(allocator);
    defer result.deinit();

    var q: usize = 0;
    while (q < Q) : (q += 1) {
        const op = try parseNextToken([]const u8, &splitter);
        if (std.mem.eql(u8, op, "+")) {
            const a = try parseNextToken(usize, &splitter);
            const b = try parseNextToken(T, &splitter);
            fennwick.add(a, b);
        } else {
            const a = try parseNextToken(usize, &splitter);
            const r = fennwick.sum(a);
            try result.append(r);
        }
    }
    return result.toOwnedSlice();
}

// Helper to parse the next token from the splitter.
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

/// Print all results
pub fn printResults(res: []i64) !void {
    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    const writer = buffered.writer();

    for (res) |value| {
        try writer.print("{d}\n", .{value});
    }

    try buffered.flush();
}