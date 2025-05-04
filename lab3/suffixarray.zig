///
/// Author: Felix Stenberg, Viktor Widin
/// 

const std = @import("std");

/// Represents a suffix during the construction process.
/// Stores the original starting index of the suffix in the input string
/// and its current ranking based on prefixes of increasing lengths.
const IX = struct {
    index: usize,
    rank: [2]i32,
};

/// Comparison function for sorting IX structs.
/// Compares suffixes first based on their primary rank (rank[0]),
/// and then by their secondary rank (rank[1]) if the primary ranks are equal.
/// This defines the lexicographical order based on the current comparison length.
///
/// Parameters:
///   - _: void - Context parameter, unused in this comparison function.
///   - a: IX - The first suffix structure to compare.
///   - b: IX - The second suffix structure to compare.
///
/// Returns:
///   `true` if suffix `a` should come before suffix `b`, `false` otherwise.
pub fn compareIX(_: void, a: IX, b: IX) bool {
    if (a.rank[0] == b.rank[0]) {
        return a.rank[1] < b.rank[1];
    } else {
        return a.rank[0] < b.rank[0];
    }
}

/// Represents a Suffix Array data structure.
/// It stores the starting indices of all suffixes of a given string,
/// sorted in lexicographical order.
pub const SuffixArray = struct {
    suffix_arr: []usize,

    /// Constructs a Suffix Array for the given string `s`.
    /// Implements a variation of the Manber-Myers algorithm (or a similar O(n log^2 n) or O(n log n) algorithm)
    /// using iterative sorting based on doubling prefix lengths.
    ///
    /// Parameters:
    ///   - allocator: The memory allocator to use for internal allocations.
    ///   - s: The input string (byte slice) for which to build the suffix array.
    ///
    /// Returns:
    ///   A `SuffixArray` struct containing the sorted suffix indices on success.
    ///
    /// Errors:
    ///   Returns an error (propagated from the allocator) if memory allocation fails
    ///   at any stage of the construction.
    pub fn init(allocator: std.mem.Allocator, s: []const u8) !SuffixArray {
        const n = s.len;
        var suffixes = try allocator.alloc(IX, n);
        defer allocator.free(suffixes);

        // Build all suffixes
        for (s, 0..) |char, i| {
            suffixes[i] = .{
                .index = i,
                .rank = .{
                    @as(i32, char),
                    if (i + 1 < n) @as(i32, s[i + 1]) else -1,
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

        return SuffixArray { .suffix_arr = suffix_arr };
    }

    /// Retrieves the starting index of the i-th lexicographically smallest suffix.
    ///
    /// Parameters:
    ///   - self: The SuffixArray instance.
    ///   - i: The rank (0-based) of the desired suffix (0 for the smallest, n-1 for the largest).
    ///
    /// Returns:
    ///   The starting index in the original string of the i-th suffix in lexicographical order.
    ///
    /// Assumption: `i` is a valid index within the bounds [0, n-1], where n is the length
    ///             of the original string used to initialize the SuffixArray.
    ///             No bounds checking is performed here.
    pub fn getSuffix(self: SuffixArray, i: usize) usize {
        return self.suffix_arr[i];
    }

    /// Deinitializes the SuffixArray, freeing the allocated memory.
    /// Must be called when the SuffixArray is no longer needed to prevent memory leaks.
    ///
    /// Parameters:
    ///   - self: The SuffixArray instance to deinitialize.
    ///   - allocator: The allocator that was originally used to `init` the SuffixArray.
    ///                It must be the same allocator instance.
    pub fn deinit(self: SuffixArray, allocator: std.mem.Allocator) void {
        allocator.free(self.suffix_arr);
    }
};
