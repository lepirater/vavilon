with Interfaces.C;

package body Ada_Part is
   use type Interfaces.C.double;

   function Eval (Op : Interfaces.C.int; A, B : Interfaces.C.double)
      return Interfaces.C.double is
   begin
      case Op is
         when 0 => return A + B;
         when 1 => return A - B;
         when 2 => return A * B;
         when 3 => return A / B;
         when others => return 0.0;
      end case;
   end Eval;
end Ada_Part;
