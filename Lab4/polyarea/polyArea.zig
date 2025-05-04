// Author: Felix Stenberg and Viktor Widin

const std = @import("std");


pub const point = struct {x: f64, y: f64};

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


