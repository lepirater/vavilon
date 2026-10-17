export fn fact(n: c_int) c_int {
    if (n < 0) return -1;
    var r: c_int = 1;
    var i: c_int = 2;
    while (i <= n) : (i += 1) r *= i;
    return r;
}

export fn isprime(n: c_int) c_int {
    if (n < 2) return 0;
    var i: c_int = 2;
    while (i * i <= n) : (i += 1) {
        if (@mod(n, i) == 0) return 0;
    }
    return 1;
}
