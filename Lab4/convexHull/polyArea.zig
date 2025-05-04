// Author: Felix Stenberg and Viktor Widin

const std = @import("std");


pub const point = struct {x: f64, y: f64};

fn lessPointsY(_: void, a: point, b: point) bool {
    return a.y < b.y;
}

fn crossProuctTwoPoints(x1: f64, y1: f64, x2: f64, y2: f64) f64 {
    return (x1 * y2) - (y1 * x2);
}

fn crossForSumPolyArea(p0: point, p1: point, p2: point) f64 {
    return crossProuctTwoPoints((p1.x-p0.x), (p1.y-p0.y), (p2.x - p0.x),(p2.y-p0.y));
}

pub fn polygon_area(points: []point) f64{
    var sum: f64 = 0;
    const p0 = points[0];
    for (1..points.len-1) |index| {
        sum += crossForSumPolyArea(p0, points[index], points[index+1]);
    }
    return sum/2;
}

const polarPoint = struct {index: usize, angle: f64, distSq: f64};

fn lessPolarPoints(_: void, a: polarPoint, b: polarPoint) bool {
    if (a.angle == b.angle) {
        return a.angle < b.angle;
    }
    return a.distSq < b.distSq;
}

pub fn Convex_Hull(points: []point, allocator: std.mem.Allocator) []point{
    // plot points onto polar cordinates relative
    // to choosen point, then start with the point
    // to the most right
    // This will be our first line, then take the 

    std.mem.sort(point, points, {}, lessPointsY);

    const leftMostP = points[0];

    const polarPointsRelativeLeftMostP = try allocator.alloc( polarPoint, n-1);
    defer allocator.free(polarPointsRelativeLeftMostP);
    
    for (1..points.len) |i| {
        polarPointsRelativeLeftMostP[i] = .{
            .index = i,
            .angle = angleRelativeToP1(leftMostP, points[i]),
            .dist_sq = dist_sq(leftMostP, points[i])
        };
    }
    
    std.mem.sort(polarPoint, polarPointsRelativeLeftMostP, {}, lessPolarPoints);


}

fn angleRelativeToP1(p1: point, p2: point) f64 {
    return std.math.atan2(p2.y-p1.y, p2.x-p1.x);
}

fn dist_sq(p1: point, p2: point) f64{
    return std.math.pow((p2.x-p1.x),2) + std.math.pow((p2.y-p1.y),2);
}

