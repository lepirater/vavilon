#[no_mangle]
pub extern "C" fn rust_part(op: i32, a: f64, b: f64) -> f64 {
    match op {
        0 => a + b,
        1 => a - b,
        2 => a * b,
        3 => a / b,
        4 => a.sqrt(),
        _ => 0.0,
    }
}
