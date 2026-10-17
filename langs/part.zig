export fn zig_part(op: i32, a: f64, b: f64) f64 {
    return switch (op) {
        0 => a + b,
        1 => a - b,
        2 => a * b,
        3 => a / b,
        else => 0,
    };
}
