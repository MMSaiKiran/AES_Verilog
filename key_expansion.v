`include "s_box.v"

module key_expansion(exp_key,done,clock,reset,start,key);
  parameter Key_Bytes_P = 10'd4;
  parameter Key_Length_P = (Key_Bytes_P<<5);
  parameter Rounds_P = 15'd10;
  
  parameter idle_P=2'd0,circ_shift_sub_byte_P=2'd1,xor_rcon_P=2'd2,xor_op_P=2'd3;
  
  input clock,reset,start;
  input [(Key_Length_P-1):0]key;
  output reg [((Rounds_P+1)<<7)-1:0]exp_key;
  output reg done;

  reg [31:0]temp_key[Key_Bytes_P-1:0];
  reg [1:0] state;
  //reg done;
  reg [3:0] count;
  //Round Constants
  reg [7:0] Rcon [Rounds_P-1:0];
  //State Matrix
  reg [0:31] word [Key_Bytes_P-1:0];
  reg [31:0] temp_word;
  integer i,j;
  
  s_box_functions SBOX_K();
  
  //Utility Function
  function [31:0] return_xor;
    input [3:0] in;
    reg [31:0] temp;
    integer i;
    begin
      temp = word[0];
      for(i=1;i<=in;i=i+1)
        temp = temp^word[i];
      return_xor = temp;
    end
  endfunction 
  
  task init_rcon();
    begin
      Rcon[0] = 8'h01;
      Rcon[1] = 8'h02;
      Rcon[2] = 8'h04;
      Rcon[3] = 8'h08;
      Rcon[4] = 8'h10;
      Rcon[5] = 8'h20;
      Rcon[6] = 8'h40;
      Rcon[7] = 8'h80;
      Rcon[8] = 8'h1b;
      Rcon[9] = 8'h36;
    end
  endtask
  
  always @(posedge clock)
  begin
    if(reset==1'b1)
      begin
        state <= 2'b00;
        done <= 1'b0;
        count <= 4'd1;
        for(i=0;i<Key_Bytes_P;i=i+1)
          word[i] <= 32'd0;
        temp_word <= 32'd0;
        init_rcon();
      end
    else 
      begin
        case(state)
          idle_P:
          begin
            if(start==1'b1)
              begin 
                for(i=0;i<Key_Bytes_P;i=i+1)
                begin
                  exp_key[(i<<5)+:32] <= key[(i<<5)+:32];//key[((i<<5)+31)-:31];
                  word[(Key_Bytes_P-1-i)] <= key[(i<<5)+:32];
                  if(i==0)
                    temp_word <= key[(i<<5)+:32];
                end
                //exp_key <= key;
                //exp_key[3:0] <= {key[96:127],key[64:95],key[32:63],key[0:31]};   
                //word[0] <= key[0:31];
                //word[1] <= key[32:63];
                //word[2] <= key[64:95];
                //Only Perform Operations on this
                //word[3] <= key[96:127];
                init_rcon(); 
                state <= circ_shift_sub_byte_P;
                done <= 1'b0;
                count <= 4'd1;
              end
            else
              begin
                for(i=0;i<Key_Bytes_P;i=i+1)
                begin
                  word[i] <= word[i];
                end
                exp_key <= exp_key;
                state <= state;
                done <= 1'b0;
                count <= 4'd1;
                temp_word <= temp_word;
              end
          end
          circ_shift_sub_byte_P:
          begin
            //Circular Left Shift Logic
            for(i=0;i<Key_Bytes_P;i=i+1)
              word[i] <= word[i];
            temp_word <= SBOX_K.sub_word({temp_word[23:0],temp_word[31:24]});
            state <= xor_rcon_P;
            done <= done;
            count <= count;
          end
          xor_rcon_P:
          begin
            for(i=0;i<Key_Bytes_P;i=i+1)
              word[i] <= word[i];
            temp_word[31:24] <= temp_word[31:24]^Rcon[(count-1)];
            temp_word[23:0] <= temp_word[23:0];
            state <= xor_op_P;
            done <= done;
            count <= count;
          end
          xor_op_P:
          begin
            if(count==Rounds_P)
              begin
                for(i=0;i<Key_Bytes_P;i=i+1)
                  exp_key[((count<<2)+(Key_Bytes_P-1-i))<<5 +: 32] <= temp_word^return_xor(i);
                //exp_key[count<<2] <= word[0]^word[3];
                //exp_key[(count<<2)+1] <= word[0]^word[3]^word[1];
                //exp_key[(count<<2)+2] <= word[0]^word[3]^word[1]^word[2];
                //exp_key[(count<<2)+3] <= word[0]^word[3]^word[1]^word[2]^word[3];
                done <= 1'b1;
                state <= idle_P;
                count <= 4'd1;
                temp_word <= temp_word;
              end
            else
              begin
                for(i=0;i<Key_Bytes_P;i=i+1)
                begin
                  exp_key[((count<<2)+(Key_Bytes_P-1-i))<<5 +: 32] <= temp_word^return_xor(i);
                  word[i] <= temp_word^return_xor(i);
                  //Write Temp Logic Here
                  if(i==Key_Bytes_P-1)
                    temp_word <= temp_word^return_xor(i);
                end
                  
                //word[0] <= word[0]^word[3];
                //word[1] <= word[0]^word[3]^word[1];
                //word[2] <= word[0]^word[3]^word[1]^word[2];
                //word[3] <= word[0]^word[3]^word[1]^word[2]^word[3];
                done <= done;
                state <= circ_shift_sub_byte_P;
                count <= count+1'b1;
              end
          end
          default:
          begin
            state <= state;
            exp_key <= exp_key;
            for(i=0; i< Key_Bytes_P ;i=i+1)
              word[i] <= word[i];
            count <= count;
            done <= done;
          end
        endcase    
      end
  end
  
endmodule 
