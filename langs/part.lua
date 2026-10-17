function part(op, a, b)
  if op == "+" then return a + b end
  if op == "-" then return a - b end
  if op == "*" then return a * b end
  if op == "/" then return a / b end
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
