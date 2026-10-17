with Interfaces.C;

package Ada_Part is
   function Eval (Op : Interfaces.C.int; A, B : Interfaces.C.double)
      return Interfaces.C.double;

   pragma Export (C, Eval, "ada_part");
end Ada_Part;
