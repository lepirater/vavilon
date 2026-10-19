function part(op, a, b)
  if op == 0 then return a + b end
  if op == 1 then return a - b end
  if op == 2 then return a * b end
  if op == 3 then return a / b end
  if op == 9 then
    local x, y = math.abs(a), math.abs(b)
    while y ~= 0 do x, y = y, x % y end
    return x
  end
  if op == 10 then
    if a == 0 or b == 0 then return 0 end
    local x, y = math.abs(a), math.abs(b)
    while y ~= 0 do x, y = y, x % y end
    return math.abs(a * b) / x
  end
  return 0
end

function number_at(index)
  local value = arg[index]
  if not value then error("missing numeric argument " .. index) end
  local normalized = value:gsub(",", ".")
  local number = tonumber(normalized)
  if not number then error("invalid numeric argument " .. value) end
  return number
end

if arg and arg[1] == "aggregate" then
  local total = part(arg[2], number_at(3), number_at(4))
  for i = 5, #arg do total = total + number_at(i) end
  print(string.format("%.17g", total))
end
