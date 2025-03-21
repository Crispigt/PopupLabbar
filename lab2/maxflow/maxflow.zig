/// Author: Felix Stenberg, Viktor Widin
///

const std = @import("std");

/// Edge structure representing a directed edge in the graph.
pub fn Edges(comptime T: type) type {
    return struct {
        capacity: T,
        flow: T,
        pointer: usize,     // The node this edge points to
        reverse: *@This(),  // Pointer to the reverse edge
    };
}

/// Represents a flow network graph.
///
/// The graph is modeled as an adjacency list where each node maintains a list
/// of outgoing edges. It provides functions to initialize the graph, add edges,
/// and deinitialize (free) the allocated memory.
///
/// Template Parameter:
///   T - The numeric type used for capacities and flows.
pub fn Graph(comptime T: type) type {
    return struct {
        const Self = @This();
        const Edge = Edges(T);

        allocator: std.mem.Allocator, 
        graphStruct: []std.ArrayList(Edge), 

        /// Initializes a new graph with a given number of nodes.
        /// Parameters:
        /// - allocator: The memory allocator to use.
        /// - size: The number of nodes in the graph.
        /// Returns an error if memory allocation fails.
        pub fn init(allocator: std.mem.Allocator, size: usize) !Self {
            const graphStruct = try allocator.alloc(std.ArrayList(Edge), size);
            for (graphStruct) |*i| {
                i.* = std.ArrayList(Edge).init(allocator);
            }

            return Self{
                .allocator = allocator,
                .graphStruct = graphStruct,
            };
        }

        /// Deinitialize the graph and free all allocated memory.
        pub fn deinit(self: Self) void {
            for (self.graphStruct) |*value| {
                value.deinit();
            }
            self.allocator.free(self.graphStruct);
        }

        /// Adds a directed edge to the graph and its residual counterpart.
        /// Parameters:
        /// - u: Source node of the edge.
        /// - v: Target node of the edge.
        /// - capacity: Capacity of the edge.
        /// Returns an error if memory allocation fails.
        pub fn add_edge(self: *Self, u: usize, v: usize, capacity: T) !void {
            try self.graphStruct[u].append(.{
                .capacity = capacity,
                .flow = 0,
                .pointer = v,
                .reverse = undefined,
            });

            try self.graphStruct[v].append(.{
                .capacity = 0,
                .flow = 0,
                .pointer = u,
                .reverse = undefined,
            });

            // Find where the reverse edge is
            const forward = &self.graphStruct[u].items[self.graphStruct[u].items.len - 1];
            const reverse = &self.graphStruct[v].items[self.graphStruct[v].items.len - 1];

            forward.reverse = reverse;
            reverse.reverse = forward;
        }

        /// PathEntry represents an entry in the augmenting path found during BFS.
        pub const PathEntry = struct {
            predecessor: usize,
            edge: *Edges(T),
        };

    };
}



/// Breadth-First Search (BFS) to find an augmenting path in the residual graph.
/// Parameters:
///   - allocator: The memory allocator to use.
///   - T: The numeric type used for capacities and flows.
///   - graph: A pointer to the flow network graph.
///   - s: The source node index.
///   - t: The sink node index.
///   - visit: A boolean array marking visited nodes.
///   - queue: An ArrayList used as a queue for BFS traversal.
///   - path: An array storing predecessor information for each node.
///
/// Returns:
///   A slice of pointers to edges that form the augmenting path, or an empty slice if no path is found.
///
/// Errors:
///   Returns an error if memory allocation fails.
pub fn bfs(
    allocator: std.mem.Allocator,
    comptime T: type,
    graph: *Graph(T),
    s: usize,
    t: usize,
    visit: []bool,
    queue: *std.ArrayList(usize),
    path: []?Graph(T).PathEntry
) ![]*Edges(T) {
    @memset(visit, false);
    @memset(path, null);


    try queue.append(s);
    visit[s] = true;

    var front: usize = 0;
    while (front < queue.items.len) : (front += 1) {
        const current = queue.items[front];

        if (current == t) {
            var pathList = std.ArrayList(*Edges(T)).init(allocator);
            var cur = t;
            while (cur != s) {
                const entry = path[cur] orelse {
                    pathList.deinit();
                    return &[_]*Edges(T){};
                };
                try pathList.append(entry.edge);
                cur = entry.predecessor;
            }
            std.mem.reverse(*Edges(T), pathList.items);
            queue.clearAndFree();
            return pathList.toOwnedSlice();
        }

        const neighbors = &graph.graphStruct[current];
        for (neighbors.items) |*edge| {
            const residual_capacity = edge.capacity - edge.flow;
            const next = edge.pointer;
            if (residual_capacity > 0 and !visit[next]) {
                path[next] = .{
                    .predecessor = current,
                    .edge = edge,
                };
                visit[next] = true;
                try queue.append(next);
            }
        }
    }
    return &[_]*Edges(T){};
}


/// Edmonds-Karp algorithm to compute the maximum flow in a flow network.
/// 
/// Parameters:
///   - allocator: The memory allocator used for dynamic memory management.
///   - T: The numeric type used for capacities and flows.
///   - edges: An array of edge definitions in the format [u, v, capacity, u1, v1, capacity1, ...],
///            where `u` and `v` are the source and target node indices respectively, and `capacity`
///            is the edge's capacity.
///   - numNodes: The total number of nodes in the graph.
///   - s: The source node index.
///   - t: The sink node index.
///
/// Returns:
///   A slice of type T containing the edges with positive flow in the following flat format:
///     [u, v, flow, u1, v1, flow1, ..., totalFlow]
///   The last element of the returned slice represents the total maximum flow computed.
///
/// Errors:
///   Returns an error if memory allocation fails or an operation fails during computation.
pub fn max_flow(
    allocator: std.mem.Allocator,
    comptime T: type,
    edges: []const T,
    numNodes: usize,        
    s: usize,
    t: usize,
) ![]T {
    var graph = try Graph(T).init(allocator, numNodes);
    defer graph.deinit();

    // Build the graph from the edges array
    var i: usize = 0;
    while (i < edges.len) : (i += 3) {
        const u: usize = @intCast(edges[i]);
        const v: usize = @intCast(edges[i + 1]);
        const capacity: T = edges[i + 2];
        try graph.add_edge(u, v, capacity);
    }

    const numNo = graph.graphStruct.len;
    const visit = try allocator.alloc(bool, numNo);
    defer allocator.free(visit);

    var queue = std.ArrayList(usize).init(allocator);
    defer queue.deinit();

    const pathInBFS = try allocator.alloc(?Graph(T).PathEntry, numNodes);

    var totFlow: T = 0;
    while (true) {
        const path = try bfs(allocator, T, &graph, s, t,visit, &queue, pathInBFS);
        defer allocator.free(path);
        if (path.len == 0) break;

        var bottle: T = std.math.maxInt(T);
        for (path) |edge| {
            const residual_capacity = edge.capacity - edge.flow;
            bottle = @min(bottle, residual_capacity);
        }

        for (path) |edge| {
            edge.flow += bottle;
            edge.reverse.flow -= bottle;
        }

        totFlow += bottle;
    }


    var result = std.ArrayList(T).init(allocator);
    defer result.deinit();

    for (graph.graphStruct, 0..) |edg, u| {
        for (edg.items) |edge| {
            if (edge.capacity > 0 and edge.flow > 0) {
                try result.append(@intCast(u));
                try result.append(@intCast(edge.pointer));
                try result.append(edge.flow);
            }
        }
    }
    try result.append(totFlow);
    // [u,v,f, u1,v1,f1 ,..., totflow ]


    return result.toOwnedSlice();
}



