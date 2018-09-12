
module s_box_functions();
    function [7:0] at(input [7:0] in);
    begin
      at[0] = in[0]^in[4]^in[5]^in[6]^in[7]^(1'b1);
      at[1] = in[0]^in[1]^in[5]^in[6]^in[7]^(1'b1);
      at[2] = in[0]^in[1]^in[2]^in[6]^in[7]^(1'b0);
      at[3] = in[0]^in[1]^in[2]^in[3]^in[7]^(1'b0);
      at[4] = in[0]^in[1]^in[2]^in[3]^in[4]^(1'b0);
      at[5] = in[1]^in[2]^in[3]^in[4]^in[5]^(1'b1);
      at[6] = in[2]^in[3]^in[4]^in[5]^in[6]^(1'b1);
      at[7] = in[3]^in[4]^in[5]^in[6]^in[7]^(1'b0);
    end
  endfunction

  function [7:0] inv_at(input [7:0] in);
    begin
      inv_at[0] = in[7]^in[5]^in[2]^(1'b1);
      inv_at[1] = in[6]^in[3]^in[0]^(1'b0);
      inv_at[2] = in[7]^in[4]^in[1]^(1'b1);
      inv_at[3] = in[5]^in[2]^in[0]^(1'b0);
      inv_at[4] = in[6]^in[3]^in[1]^(1'b0);
      inv_at[5] = in[7]^in[4]^in[2]^(1'b0);
      inv_at[6] = in[5]^in[3]^in[0]^(1'b0);
      inv_at[7] = in[6]^in[4]^in[1]^(1'b0);
    end
  endfunction
  
  function [7:0] isomorphic_map(input [7:0] in);
    begin
      isomorphic_map[0] = in[6]^in[1]^in[0];
      isomorphic_map[1] = in[6]^in[4]^in[1];
      isomorphic_map[2] = in[7]^in[4]^in[3]^in[2]^in[1];
      isomorphic_map[3] = in[7]^in[6]^in[2]^in[1];
      isomorphic_map[4] = in[7]^in[5]^in[3]^in[2]^in[1];
      isomorphic_map[5] = in[7]^in[5]^in[3]^in[2];
      isomorphic_map[6] = in[7]^in[6]^in[4]^in[3]^in[2]^in[1];
      isomorphic_map[7] = in[7]^in[5];
    end
  endfunction
  
  function [7:0] inv_isomorphic_map(input [7:0] in);
    begin
      inv_isomorphic_map[0] = in[6]^in[5]^in[4]^in[2]^in[0];
      inv_isomorphic_map[1] = in[5]^in[4];
      inv_isomorphic_map[2] = in[7]^in[4]^in[3]^in[2]^in[1];
      inv_isomorphic_map[3] = in[5]^in[4]^in[3]^in[2]^in[1];
      inv_isomorphic_map[4] = in[6]^in[5]^in[4]^in[2]^in[1];
      inv_isomorphic_map[5] = in[6]^in[5]^in[1];
      inv_isomorphic_map[6] = in[6]^in[2];
      inv_isomorphic_map[7] = in[7]^in[6]^in[5]^in[1];
    end
  endfunction
  
  function [3:0] addition(input [3:0] in1,in2);
    begin
      addition = in1^in2;
    end
  endfunction
  
  function [3:0] square(input [3:0] in);
    begin
      square[0] = in[3]^in[1]^in[0];
      square[1] = in[2]^in[1];
      square[2] = in[3]^in[2];
      square[3] = in[3];
    end
  endfunction
  
  function [3:0] const_mul(input [3:0] in);
    begin
      const_mul[0] = in[2];
      const_mul[1] = in[3];
      const_mul[2] = in[3]^in[2]^in[1]^in[0];
      const_mul[3] = in[2]^in[0];
    end
  endfunction
  
  function [1:0] mul_gf2(input [1:0] in1,in2);
    begin
  
      mul_gf2[0] = (in1[1]&in2[1])^(in1[0]&in2[0]);
      mul_gf2[1] = (in1[1]&in2[1])^(in1[0]&in2[1])^(in1[1]&in2[0]);
    end
  endfunction
  function [1:0] mul_const_gf2(input [1:0] in);
    begin
      mul_const_gf2 = mul_gf2(in,2'b10);
    end
  endfunction
  
  function [3:0] mul_gf4(input [3:0] in1,in2);
    reg [1:0] t1,t2,t3;
    begin
      t1 = mul_const_gf2(mul_gf2(in1[3:2],in2[3:2]));
      t3 = mul_gf2((in1[3:2]^in1[1:0]),(in2[3:2]^in2[1:0]));
      t2 = mul_gf2(in1[1:0],in2[1:0]);
      mul_gf4[3:2] = t3^t2;
      mul_gf4[1:0] = t1^t2;
    end
  endfunction
  
  function [3:0] mul_inv_gf4(input [3:0] in);
    begin
      mul_inv_gf4[3] = in[3]^(in[3]&in[2]&in[1])^(in[3]&in[0])^in[2];
      mul_inv_gf4[2] = (in[3]&in[2]&in[1])^(in[3]&in[2]&in[0])^(in[3]&in[0])^in[2]^(in[2]&in[1]);
      mul_inv_gf4[1] = in[3]^(in[3]&in[2]&in[1])^(in[3]&in[1]&in[0])^in[2]^(in[2]&in[0])^in[1];
      mul_inv_gf4[0] = (in[3]&in[2]&in[1])^(in[3]&in[2]&in[0])^(in[3]&in[1])^(in[3]&in[1]&in[0])^(in[3]&in[0])^in[2]^(in[2]&in[1])^(in[2]&in[1]&in[0])^in[1]^in[0];
    end
  endfunction
  
  function [7:0] mul_inv(input [7:0] in);
    reg [7:0] t1,t2;
    reg [3:0] t3,t4,t5,t6,t7;
    begin
      t1 = isomorphic_map(in);
      t3 = const_mul(square(t1[7:4]));
      t4 = mul_gf4(t1[3:0],(t1[7:4]^t1[3:0]));
      t5 = mul_inv_gf4((t3^t4));
      t6 = mul_gf4(t5,t1[7:4]);
      t7 = mul_gf4(t5,(t1[7:4]^t1[3:0]));
      mul_inv = inv_isomorphic_map({t6,t7});
    end
  endfunction
  
  function [7:0] sub_byte(input [7:0] in);
    begin
      sub_byte = at(mul_inv(in));
    end
  endfunction
  
  function [31:0] sub_word(input [31:0] in);
    begin
      sub_word = {sub_byte(in[31:24]),sub_byte(in[23:16]),sub_byte(in[15:8]),sub_byte(in[7:0])};
    end
  endfunction
  
  function [7:0] inv_sub_byte(input [7:0] in);
    begin
      inv_sub_byte = mul_inv(inv_at(in));
    end
  endfunction
  
  function [31:0] inv_sub_word(input [31:0] in);
    begin
      inv_sub_word = {inv_sub_byte(in[31:24]),inv_sub_byte(in[23:16]),inv_sub_byte(in[15:8]),inv_sub_byte(in[7:0])};
    end
  endfunction
    
endmodule 