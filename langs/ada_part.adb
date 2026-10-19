function Ada_Part (Op : Integer; A, B : Long_Float) return Long_Float is
begin
   case Op is
      when 0 => return A + B;
      when 1 => return A - B;
      when 2 => return A * B;
      when 3 => return A / B;
      when others => return 0.0;
   end case;
end Ada_Part;
