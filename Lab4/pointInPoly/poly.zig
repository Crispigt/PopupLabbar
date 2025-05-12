// Author: Felix Stenberg and Viktor Widin

const std = @import("std");

/// A 2D point with floating-point coordinates.
pub const point = struct { x: f64, y: f64 };

/// Compares two points for sorting: first by Y-coordinate (ascending), then by X (ascending).
fn lessPointsY(_: void, a: point, b: point) bool {
    return a.y < b.y or (a.y == b.y and a.x < b.x);
}

/// Computes the 2D cross product of vectors (x1, y1) and (x2, y2).
/// The result is the z-component of the 3D cross product, indicating the area of the parallelogram.
fn crossProuctTwoPoints(x1: f64, y1: f64, x2: f64, y2: f64) f64 {
    return (x1 * y2) - (y1 * x2);
}

/// Computes the cross product of vectors from p0 to p1 and from p0 to p2.
/// A positive value indicates that p2 is counter-clockwise from the line p0-p1.
/// Zero indicates colinearity; negative indicates clockwise.
fn crossProductThreePoints(p0: point, p1: point, p2: point) f64 {
    return crossProuctTwoPoints((p1.x - p0.x), (p1.y - p0.y), (p2.x - p0.x), (p2.y - p0.y));
}

/// Computes the signed area of a polygon.
/// The polygon is defined by a array of ordered 2D points (either clockwise or counter-clockwise).
/// The result is positive if the 2D points are ordered counter-clockwise.
/// Requires at least 3 points to form a polygon, otherwise it returns 0.
/// Parameters:
///   - points: A non-empty array of points.
/// Returns:
///   Area of the polygon, positive if points are ordered counter-clockwise.
pub fn polygon_area(points: []point) f64 {
    if (points.len < 3) {
        return 0;
    }

    var sum: f64 = 0;
    const p0 = points[0];
    for (1..points.len - 1) |index| {
        sum += crossProductThreePoints(p0, points[index], points[index + 1]);
    }
    return sum / 2;
}

/// Represents a point in polar coordinates relative to a reference point.
/// Used for sorting points by angle and distance in convex hull computation.
const polarPoint = struct { index: usize, angle: f64, distSq: f64 };

/// Compares two polarPoints first by angle, then by distance squared.
/// Ensures points are sorted in increasing polar angle order, with closer points first if angles are equal.
fn lessPolarPoints(_: void, a: polarPoint, b: polarPoint) bool {
    if (a.angle != b.angle) {
        return a.angle < b.angle;
    } else {
        return a.distSq < b.distSq;
    }
}

/// Computes the convex hull of a set of 2D points.
/// The input slice is modified (sorted by Y-coordinate and deduplicated).
/// Parameters:
///   - points: A non-empty slice of points. The order is modified during processing.
///   - allocator: Used for temporary memory allocations and the returned hull.
/// Returns:
///   A newly allocated slice of points forming the convex hull in counter-clockwise order.
/// Errors:
///   Possible allocation errors, such as OutOfMemory, if allocation fails.
pub fn Convex_Hull(points: []point, allocator: std.mem.Allocator) ![]point {
    std.mem.sort(point, points, {}, lessPointsY);

    var unique = std.ArrayList(point).init(allocator);
    defer unique.deinit();
    try unique.append(points[0]);
    for (points[1..]) |p| {
        const last = unique.items[unique.items.len - 1];
        if (!(p.x == last.x and p.y == last.y)) {
            try unique.append(p);
        }
    }

    if (unique.items.len == 1) {
        return try allocator.dupe(point, &[_]point{unique.items[0]});
    }
    if (unique.items.len == 2) {
        if (unique.items[0].x == unique.items[1].x and unique.items[0].y == unique.items[1].y) {
            return try allocator.dupe(point, &[_]point{unique.items[0]});
        } else {
            return try allocator.dupe(point, unique.items);
        }
    }

    const leftMostP = unique.items[0];

    const polarPointsRelativeLeftMostP = try allocator.alloc(polarPoint, unique.items.len - 1);
    defer allocator.free(polarPointsRelativeLeftMostP);

    for (1..unique.items.len) |i| {
        polarPointsRelativeLeftMostP[i - 1] = .{
            .index = i,
            .angle = angleRelativeToP1(leftMostP, unique.items[i]),
            .distSq = dist_sq(leftMostP, unique.items[i]),
        };
    }

    std.mem.sort(polarPoint, polarPointsRelativeLeftMostP, {}, lessPolarPoints);

    var stack = std.ArrayList(point).init(allocator);
    defer stack.deinit();

    try stack.append(leftMostP);
    try stack.append(unique.items[polarPointsRelativeLeftMostP[0].index]);

    for (1..polarPointsRelativeLeftMostP.len) |i| {
        const third = unique.items[polarPointsRelativeLeftMostP[i].index];
        while (true) {
            if (stack.items.len < 2) break;
            const first = stack.items[stack.items.len - 2];
            const second = stack.items[stack.items.len - 1];
            const cross = crossProductThreePoints(first, second, third);
            if (cross > 0) {
                break;
            } else {
                _ = stack.pop();
            }
        }
        try stack.append(third);
    }

    return stack.toOwnedSlice();
}

/// Tolerance for floating-point comparisons in geometric calculations.
const tolerance: f64 = 1e-4;

/// Determines whether a point lies inside, on the edge, or outside a polygon.
/// The polygon is defined by a closed loop of 2D points.
/// Uses the angle approach with a tolerance of 1e-4 for floating-point comparisons.
/// Parameters:
///   - p: The point to test.
///   - poly: Array of polygon 2D points, ordered either clockwise or counter-clockwise.
/// Returns:
///   1 if inside, 0 if on the edge, -1 if outside.
pub fn inside_poly(p: point, poly: []point) i32 {
    var sumAngle: f64 = 0.0;
    for (0..poly.len) |i| {
        const angle = angleThreePoints(p, poly[i], poly[(i + 1) % poly.len]);
        sumAngle += angle;

        if (pointOnSeg(p, poly[i], poly[(i + 1) % poly.len])) {
            return 0;
        }
    }
    sumAngle = @abs(sumAngle);

    if (sumAngle < tolerance) {
        return -1;
    } else if ((sumAngle - 2 * std.math.pi) < tolerance) {
        return 1;
    }
    return 0;
}

/// Checks if a point lies on the line segment between two other points.
/// Parameters:
///   - p0: The point to check.
///   - p1: First endpoint of the segment.
///   - p2: Second endpoint of the segment.
/// Returns:
///   True if p0 is collinear with and between p1 and p2, false otherwise.
fn pointOnSeg(p0: point, p1: point, p2: point) bool {
    const colin = crossProductThreePoints(p1, p0, p2);
    if (colin > tolerance or colin < -tolerance) {
        return false;
    }

    const dot = dotProuctThreePoints(p0, p1, p2);
    if (dot > tolerance) {
        return false;
    }

    return true;
}

/// Computes the dot product of two 2D vectors (x1, y1) and (x2, y2).
fn dotProuctTwoPoints(x1: f64, y1: f64, x2: f64, y2: f64) f64 {
    return (x1 * x2) + (y1 * y2);
}

/// Computes the dot product of vectors from p0 to p1 and from p0 to p2.
fn dotProuctThreePoints(p0: point, p1: point, p2: point) f64 {
    return dotProuctTwoPoints((p1.x - p0.x), (p1.y - p0.y), (p2.x - p0.x), (p2.y - p0.y));
}

/// Computes the signed angle at p0 between vectors p0-p1 and p0-p2.
/// The result is in radians, normalized to the range (-pi, pi].
fn angleThreePoints(p0: point, p1: point, p2: point) f64 {
    const angle1 = angleRelativeToP1(p0, p1);
    const angle2 = angleRelativeToP1(p0, p2);

    var diff = angle2 - angle1;
    while (diff <= -std.math.pi) {
        diff += 2.0 * std.math.pi;
    }
    while (diff > std.math.pi) {
        diff -= 2.0 * std.math.pi;
    }
    return diff;
}

/// Computes the angle in radians from p1 to p2 relative to the positive X-axis.
/// The angle ranges from -pi to pi, equivalent to std.math.atan2(dy, dx).
fn angleRelativeToP1(p1: point, p2: point) f64 {
    return std.math.atan2(p2.y - p1.y, p2.x - p1.x);
}

/// Computes the squared Euclidean distance between two points.
fn dist_sq(p1: point, p2: point) f64 {
    return std.math.pow(f64, (p2.x - p1.x), 2) + std.math.pow(f64, (p2.y - p1.y), 2);
}