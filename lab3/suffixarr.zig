///
/// Author: Felix Stenberg, Viktor Widin
/// 

const std = @import("std");

/// Represents an intermediate structure used during suffix array construction.
/// It holds the original starting index of the suffix and its current rank pair.
const IX = struct {
    index: usize,
    rank: [2]i32,
};

pub fn compareIX(_: void, a: IX, b: IX) bool {
    if (a.rank[0] == b.rank[0]) {
        return a.rank[1] < b.rank[1];
    } else {
        return a.rank[0] < b.rank[0];
    }
}
/// Compares two IX structs based lexicographically on their rank pairs.
/// This function is used to sort suffixes during the construction process.
///
/// Parameters:
///   - _: void context parameter (unused).
///   - a: The first IX struct to compare.
///   - b: The second IX struct to compare.
///
/// Returns:
///   `true` if suffix `a` should come before suffix `b` lexicographically based on ranks, `false` otherwise.
pub fn buildSuffixArr(allocator: std.mem.Allocator, word: []const u8) ![]usize {
    const n = word.len;
    var suffixes = try allocator.alloc(IX, n);
    defer allocator.free(suffixes);

    for (word, 0..) |char, i| {
        suffixes[i] = .{
            .index = i,
            .rank = .{
                @as(i32, char),
                if (i + 1 < n) @as(i32, word[i + 1]) else -1,
            },
        };
    }

    std.mem.sort(IX, suffixes, {}, compareIX);

    var indx = try allocator.alloc(usize, n);
    defer allocator.free(indx);

    var k: usize = 4;
    while (k < 2 * n) {
        var rank: i32 = 0;
        var prev_rank = suffixes[0].rank[0];
        suffixes[0].rank[0] = rank;
        indx[suffixes[0].index] = 0;

        for (1..n) |r| {
            if (suffixes[r].rank[0] == prev_rank and
                suffixes[r].rank[1] == suffixes[r - 1].rank[1])
            {
                prev_rank = suffixes[r].rank[0];
                suffixes[r].rank[0] = rank;
            } else {
                prev_rank = suffixes[r].rank[0];
                rank += 1;
                suffixes[r].rank[0] = rank;
            }
            indx[suffixes[r].index] = r;
        }

        for (suffixes) |*suffix| {
            const next_index = suffix.index + k / 2;
            suffix.rank[1] = if (next_index < n)
                suffixes[indx[next_index]].rank[0] else -1;
        }

        std.mem.sort(IX, suffixes, {}, compareIX);
        k *= 2;
    }

    var suffix_arr = try allocator.alloc(usize, n);
    for (suffixes, 0..) |suffix, i| {
        suffix_arr[i] = suffix.index;
    }

    return suffix_arr;
}

/// Represents a Suffix Array data structure.
/// It stores the starting indices of all suffixes of a given string, sorted lexicographically.
/// This implementation uses a suffix doubling (also known as prefix doubling or Manber-Myers variation)
/// algorithm with O(n log^2 n).
pub const SuffixArray = struct {
    sa: []usize,

    pub fn init(allocator: std.mem.Allocator, s: []const u8) !SuffixArray {
        const sa = try buildSuffixArr(allocator, s);
        return SuffixArray { .sa = sa };
    }

    pub fn get(self: SuffixArray, index: usize) usize {
        return self.sa[index];
    }

    pub fn deinit(self: SuffixArray, allocator: std.mem.Allocator) void {
        allocator.free(self.sa);
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const allocator = std.heap.page_allocator;

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const aa = arena.allocator();

    var buffer = std.ArrayList(u8).init(aa);
    var line_buf = std.ArrayList(u8).init(aa);

    var stdout = std.io.getStdOut();
    var buffered_writer = std.io.bufferedWriter(stdout.writer());
    const writer = buffered_writer.writer();

    while (true) {
        buffer.clearRetainingCapacity();
        stdin.streamUntilDelimiter(buffer.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const s = buffer.items;
        if (s.len == 0) break;

        line_buf.clearRetainingCapacity();
        stdin.streamUntilDelimiter(line_buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => return error.InvalidInput,
            else => return err,
        };
        const query_line = line_buf.items;

        var tokenizer = std.mem.tokenizeAny(u8, query_line, " \t\r\n");
        const m_str = tokenizer.next() orelse return error.InvalidInput;
        const m = try std.fmt.parseInt(usize, m_str, 10);

        var queries = std.ArrayList(usize).init(aa);
        for (0..m) |_| {
            const k_str = tokenizer.next() orelse return error.InvalidInput;
            const k = try std.fmt.parseInt(usize, k_str, 10);
            try queries.append(k);
        }

        const sa = try SuffixArray.init(aa, s);
        defer sa.deinit(aa);

        for (queries.items) |k| {
            try std.fmt.format(writer, "{} ", .{sa.get(k)});
        }
        try writer.writeAll("\n");
    }

    try buffered_writer.flush();
}