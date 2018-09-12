module Mix_Column();
  function [7:0] mul_2(input [7:0] byte);
    begin 
      if(byte[7]==1'b0) 
        mul_2 = byte<<1;
      else
        mul_2 = (byte<<1)^(8'h1b);
    end
  endfunction

  function [7:0] mul_3(input [7:0] byte);  
    begin
      if(byte[7]==1'b0)
        mul_3 = (byte<<1)^(byte);
      else
        mul_3 = (byte<<1)^(byte)^(8'h1b);
    end
  endfunction


  function [7:0] mix_column0(input [31:0] word);
    begin
      mix_column0 = word[7:0]^word[15:8]^mul_3(word[23:16])^mul_2(word[31:24]);
    end
  endfunction

  function [7:0] mix_column1(input [31:0] word);
    begin
      mix_column1 = word[7:0]^mul_3(word[15:8])^mul_2(word[23:16])^word[31:24];
    end
  endfunction

  function [7:0] mix_column2(input [31:0] word);
    begin
      mix_column2 = mul_3(word[7:0])^mul_2(word[15:8])^word[23:16]^word[31:24];
    end
  endfunction

  function [7:0] mix_column3(input [31:0] word);
    begin
      mix_column3 = mul_2(word[7:0])^word[15:8]^word[23:16]^mul_3(word[31:24]);
   end
  endfunction

  function [0:31] mix_column(input [0:31] word);
    begin
      mix_column = {mix_column0(word),mix_column1(word),mix_column2(word),mix_column3(word)};
    end
  endfunction

endmodule 