function gcd(a, b)
  while b ~= 0 do a, b = b, a % b end
  return a
end

function lcm(a, b)
  if a == 0 or b == 0 then return 0 end
  return a * b / gcd(a, b)
end
