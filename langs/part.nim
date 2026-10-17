proc nim_part*(op: cint, a, b: cdouble): cdouble {.exportc, dynlib.} =
  case op
  of 0: a + b
  of 1: a - b
  of 2: a * b
  of 3: a / b
  else: 0
