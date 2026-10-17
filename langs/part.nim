proc mul*(a, b: cint): cint {.exportc, dynlib.} =
  a * b

proc divi*(a, b: cint): cint {.exportc, dynlib.} =
  if b == 0: return 0
  a div b
