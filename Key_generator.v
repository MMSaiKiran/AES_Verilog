module key_generator(key_out,key_gen,start,clock,preset,iv);
  parameter Key_Bytes_P = 4'd4;
  parameter KEY_LEN_P = (Key_Bytes_P<<5);
  parameter LEN_VALUE_P = 4'd8;
  input [KEY_LEN_P-1:0] iv;
  input clock,preset,start;
  output reg [KEY_LEN_P-1:0]key_out;
  output reg key_gen;
  wire feed_back; 
  reg [LEN_VALUE_P:0]count;
  reg [KEY_LEN_P-1:0]temp;
  
  
  //128,126,101,99
  assign feed_back = temp[127]^temp[125]^temp[100]^temp[98]; 
  
  
  always @(posedge clock)
  begin
    if(preset==1'b1)
    begin
      key_out <= key_out;
      key_gen <= 1'b0;
      count <= 8'hFF;
      temp <= iv;
    end
    else if(start==1'b1)
    begin 
      if(count==8'd0)
      begin
        key_out <= {temp[126:0],feed_back};
        temp <= {temp[126:0],feed_back};
        key_gen <= 1'b1;
        count <= 8'hFF;
      end
      else
      begin
        temp <= {temp[126:0],feed_back};
        key_out <= key_out;
        count <= count-1;
        key_gen <= 1'b0; 
      end
    end
    else
    begin
      temp <= temp;
      count <= count;
      key_gen <= key_gen;
      key_out <= key_out;
    end 
  end
  
  
endmodule 


module tb_keygen();
  reg clock,preset;
  reg [127:0] iv;
  wire key_gen;
  wire [127:0] key;
  
  key_generator KEY_GEN(.key_out(key),.key_gen(key_gen),.clock(clock),.preset(preset),.iv(iv));
  
  
  //Clock Generator
  initial
  begin
    clock = 1'b1;
    forever
      #5 clock = ~clock;
  end
  
  initial
  begin
    iv = 128'd1234567;
    #3 preset = 1'b1;
    #10 preset = 1'b0;
  end
  
endmodule 