///
/// Author: Felix Stenberg, Viktor Widin
/// 

const std = @import("std");
const SuffixSort = @import("suffixarray.zig");

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

        const suffix_arr = try SuffixSort.SuffixArray.init(aa, s);
        defer suffix_arr.deinit(aa);

        for (queries.items) |k| {
            try std.fmt.format(writer, "{} ", .{suffix_arr.getSuffix(k)});
        }
        try writer.writeAll("\n");
    }

    try buffered_writer.flush();
}