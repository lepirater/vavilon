export fn zig_part(op: c_int, a: f64, b: f64) f64 {
    switch (op) {
        0 => return a + b,
        1 => return a - b,
        2 => return a * b,
        3 => return a / b,
        7 => {
            const n: c_int = @intFromFloat(a);
            if (n < 0) return 0;
            var r: f64 = 1;
            var i: c_int = 2;
            while (i <= n) : (i += 1) r *= @floatFromInt(i);
            return r;
        },
        8 => {
            const n: c_int = @intFromFloat(a);
            if (n < 2) return 0;
            var i: c_int = 2;
            while (i * i <= n) : (i += 1) {
                if (@mod(n, i) == 0) return 0;
            }
            return 1;
        },
        else => return 0,
    }
}
