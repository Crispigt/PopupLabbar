/// Author: Felix Stenberg
const std = @import("std");

/// Node structure holding a representative for the set (parent) and a rank
/// used in union-by-rank logic. Parameterized by type T.
pub fn Node(comptime T: type) type {
    return struct {
        parent: T,
        rank: u32,
    };
}

/// A generic Union-Find (Disjoint Set Union) data structure, parameterized by T.
/// T must be castable to and from an integer type for indexing to work correctly.
pub fn UnionFind(comptime T: type) type {
    return struct {
        const Self = @This();
        const NodeType = Node(T);

        allocator: std.mem.Allocator,
        nodes: []NodeType,
        
        /// Initializes a Union-Find structure with `size` elements.
        /// Parameters:
        /// - `allocator`: Zig memory allocator (e.g., std.heap.page_allocator).
        /// - `size`: Number of elements in the underlying array (0-based).
        /// 
        /// Returns:
        /// - A UnionFind instance with nodes initialized with rank zero and them self as root.
        /// - Errors: Allocation failures (e.g., out-of-memory).
        pub fn init(allocator: std.mem.Allocator, size: usize) !Self {
            const nodes = try allocator.alloc(NodeType, size);
            for (nodes, 0..) |*node, i| {
                const val: T = std.math.cast(T, i).?;
                node.parent = val;
                node.rank = 0;
            }
            return Self{
                .allocator = allocator,
                .nodes = nodes,
            };
        }

        /// De-initializes the Union-Find structure, freeing allocated memory.
        ///
        /// This must be called when the Union-Find is no longer needed to
        /// avoid memory leaks.
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.nodes);
        }

        /// Merges (unites) the sets that contain `a` and `b`.
        /// 
        /// Parameters:
        /// - `a`: An element of the first set to be merged.
        /// - `b`: An element of the second set to be merged.
        /// 
        pub fn unionN(self: *Self, a: T, b: T) void {
            const root_a = self.find(a);
            const root_b = self.find(b);
            if (root_a == root_b) return;

            if (self.nodes[root_a].rank > self.nodes[root_b].rank) {
                self.nodes[root_b].parent = root_a;
            } else if (self.nodes[root_a].rank < self.nodes[root_b].rank) {
                self.nodes[root_a].parent = root_b;
            } else {
                self.nodes[root_b].parent = root_a;
                self.nodes[root_a].rank += 1;
            }
        }

        /// Checks if two elements `a` and `b` are in the same set.
        ///
        /// Parameters:
        /// - `a`: The first element.
        /// - `b`: The second element.
        /// 
        /// Returns:
        /// - True if `a` and `b` share the same root, false otherwise.
        pub fn same(self: *Self, a: T, b: T) bool {
            return self.find(a) == self.find(b);
        }

        /// Finds the representative (root) of the set that contains `value`.
        /// 
        /// Parameters:
        /// - `value`: An element whose set root we want to find.
        /// 
        /// Returns:
        /// - Returns the root element of `value`'s set.
        pub fn find(self: *Self, value: T) T {
            const index = @as(usize, @intCast(value));
            var node = &self.nodes[index];
            if (node.parent != value) {
                const root = self.find(node.parent);
                node.parent = root;
                return root;
            }
            return value;
        }
    };
}

/// Reads entire input into a buffer without size restrictions.
pub fn readInput(allocator: std.mem.Allocator, reader: anytype) ![]u8 {
    return try reader.readToEndAlloc(allocator, std.math.maxInt(usize));
}

/// Parse, set up based on input from kattis, and then run the union find algo.
pub fn parseAndRunCombinedArray(allocator: std.mem.Allocator, data: []const u8) ![]bool {
    var splitter = std.mem.splitAny(u8, data, " \n");

    // Parse N and Q
    const N = try parseNextToken(usize, &splitter);
    const Q = try parseNextToken(usize, &splitter);

    // Initialize Union-Find structure
    var unionF = try UnionFind(u32).init(allocator, N);
    defer unionF.deinit();

    // std.debug.print("Here\n", .{});

    var result = std.ArrayList(bool).init(allocator);
    defer result.deinit();

    // Process each query
    var q: usize = 0;
    while (q < Q) : (q += 1) {
        const op = try parseNextToken([]const u8, &splitter);
        const a = try parseNextToken(u32, &splitter);
        const b = try parseNextToken(u32, &splitter);

        if (std.mem.eql(u8, op, "=")) {
            unionF.unionN(a, b);
        } else {
            const sameResult = unionF.same(a, b);
            try result.append(sameResult);
        }
    }

    return result.toOwnedSlice();
}

// Helper to parse the next token from the splitter.
fn parseNextToken(comptime T: type, splitter: anytype) !T {
    while (splitter.next()) |token| {
        if (token.len == 0) continue;
        return switch (T) {
            []const u8 => token, // Use the slice directly without allocation
            else => try std.fmt.parseInt(T, token, 10),
        };
    }
    return error.UnexpectedEndOfInput;
}

/// Print all results.
pub fn printResults2(res: []bool) !void {
    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    const writer = buffered.writer();
    for (res) |value| {
        if (value) {
            try writer.print("yes\n", .{});
        } else {
            try writer.print("no\n", .{});
        }
    }
    try buffered.flush();
}
