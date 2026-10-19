#ifndef VAVILON_CHAIN_H
#define VAVILON_CHAIN_H

double rust_part(int op, double a, double b);
double go_part(int op, double a, double b);
double zig_part(int op, double a, double b);
double d_part(int op, double a, double b);
double nim_part(int op, double a, double b);
double cpp_part(int op, double a, double b);
double ada_part(int op, double a, double b);
double nab_part(int op, double a, double b);
double nab_unary(const char *fn, double a);
double nab_binary(const char *fn, double a, double b);

#endif
