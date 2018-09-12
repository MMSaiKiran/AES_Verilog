module Shift_Row();
  
  function [31:0] shift_row0(input [31:0]w0,w1,w2,w3);
  begin
    shift_row0 = {w0[31:24],w1[23:16],w2[15:8],w3[7:0]};
  end
  endfunction

  function [31:0] shift_row1(input [31:0]w0,w1,w2,w3);
  begin
    shift_row1 = {w1[31:24],w2[23:16],w3[15:8],w0[7:0]};
  end
  endfunction
  
  function [31:0] shift_row2(input [31:0]w0,w1,w2,w3);
  begin
    shift_row2 = {w2[31:24],w3[23:16],w0[15:8],w1[7:0]};
  end
  endfunction
  
  function [31:0] shift_row3(input [31:0]w0,w1,w2,w3);
  begin
    shift_row3 = {w3[31:24],w0[23:16],w1[15:8],w2[7:0]};
  end
  endfunction
  
endmodule 
