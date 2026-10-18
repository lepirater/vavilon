#!/usr/bin/env perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

sub number {
    my ($value) = @_;
    $value =~ s/,/./;
    die "invalid numeric argument $value\n" unless looks_like_number($value);
    return $value + 0;
}

sub part {
    my ($op, $a, $b) = @_;
    $a = number($a);
    $b = number($b);
    return $a + $b if $op eq '+';
    return $a - $b if $op eq '-';
    return $a * $b if $op eq '*';
    return $a / $b if $op eq '/';
    return 0;
}

if (@ARGV && $ARGV[0] eq 'eval') {
    die "usage: $0 eval <op> <a> <b>\n" unless @ARGV == 4;
    print sprintf("%.17g", part(@ARGV[1..3]));
}
