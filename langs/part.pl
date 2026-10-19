my ($mode, $op, $a, $b) = @ARGV;
if ($mode eq "eval") {
    if ($op == 0) { print $a + $b; }
    elsif ($op == 1) { print $a - $b; }
    elsif ($op == 2) { print $a * $b; }
    elsif ($op == 3) { print $a / $b; }
    elsif ($op == 16) { print ($a + $b) / 2; }
    else { print 0; }
}
