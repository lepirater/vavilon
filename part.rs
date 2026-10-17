#[no_mangle]
pub extern "C" fn rs_sqrt(a: f64) -> f64 {
    a.sqrt()
}

#[no_mangle]
pub extern "C" fn rs_abs(a: f64) -> f64 {
    a.abs()
}

#[no_mangle]
pub extern "C" fn rs_mod(a: f64, b: f64) -> f64 {
    a % b
}
