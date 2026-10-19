extern (C) double d_part(int op, double a, double b) {
    switch (op) {
        case 0: return a + b;
        case 1: return a - b;
        case 2: return a * b;
        case 3: return a / b;
        case 5: return a * a;
        default: return 0;
    }
}
