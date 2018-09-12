//Author: M. Maruthi Sai Kiran
//AES - (Advanced Encryption Satndard)
//Symmetrical Block Cipher
//Data Length - 128 bits, Key Length - 128,192,256 bits
//Electronic Code book Mode

`include "MixColumn.v"
`include "shift_row.v"
`include "key_expansion.v"
`include "Key_generator.v"

module aes_core(cipher_text,done,reset,clock,key,plain_text);
  parameter DATA_LEN = 8'd127;
  parameter Key_Bytes_P = 10'd4;
  parameter KEY_LEN_P = (Key_Bytes_P<<5);
  parameter Rounds_P = 15'd10;
  parameter init=4'd0,
            key_generate=4'd1,
            expand_key = 4'd2,
            add_key=4'd3,
            sub_bytes=4'd4,
            shift_row=4'd5,
            mix_column=4'd6,
            add_round_key=4'd7,
            finish=4'd8;
  input clock;
  input reset;
  input [DATA_LEN:0] plain_text;
  input [KEY_LEN_P-1:0] key;
  output [DATA_LEN:0] cipher_text;
  output reg done;
  
  
  reg [3:0] state;
  reg [14:0] count;
  
  //For state Matrix
  reg [0:31]word[3:0];
  
  //For Key Expansion
  reg key_expand_start;
  wire [((Rounds_P+1)<<7)-1:0]exp_key;
  wire key_gen_start,key_generated;
  wire [KEY_LEN_P-1:0]key;
  wire key_exp_done;
  
  integer i;
  
  assign key_generated = 1'b1;
  assign key_gen_start = (state==key_generate);
  
  //Instantiation
  //key_generator KEY_GEN (.key_out(key),.key_gen(key_generated),.start(key_gen_start),.clock(clock),.preset(reset),.iv(iv));
  key_expansion KEY_EXP(.exp_key(exp_key),.done(key_exp_done),.clock(clock),.reset(reset),.start(key_expand_start),.key(key));
  Mix_Column M();
  Shift_Row S();
  s_box_functions SBOX();
  
  
  assign cipher_text = {word[0],word[1],word[2],word[3]};
  /*always @(posedge clock)
  begin
    if(reset==1'b1)
      begin
        cipher_text <= 128'd0;
      end
    else if(done==1'b1)
      begin
        cipher_text <= {word[3],word[2],word[1],word[0]}; 
      end
    else
      begin
        cipher_text <= cipher_text;
      end
  end
  */
  always @(posedge clock)
  begin
    if(reset==1'b1)
      begin
        state <= init;
        done <= 1'b0;
        count <= 12'd0;
        key_expand_start <= 1'b0;
        for(i=0;i<4;i=i+1)
          word[i] <= 32'd0;
      end
    else
      begin
        case(state)
          init:
          begin
            for(i=0;i<4;i=i+1)
              word[(3-i)] <= plain_text[(i<<5)+:32];
            done <= 1'b0;
            count <= 12'd0;
            state <= key_generate;
            key_expand_start <= 1'b0;
          end
          key_generate:
          begin
            for(i=0;i<4;i=i+1)
              word[i] <= word[i];
            done<=done;
            count<=count;
            if(key_generated==1'b1)
            begin
              state <= expand_key;
              key_expand_start <= 1'b1;
            end
            else
            begin
              state <= state;
              key_expand_start <= key_expand_start;
            end
          end
          expand_key:
          begin
            for(i=0;i<4;i=i+1)
              word[i] <= word[i];
            done<=done;
            count<=count;
            state <= add_key;
            if(key_exp_done==1'b1)
              key_expand_start <= 1'b0;
            else
              key_expand_start <= key_expand_start;
          end
          add_key:
          begin
            for(i=0;i<4;i=i+1)
              word[i] <= word[i]^exp_key[((3-i)<<5)+:32];
            state <= sub_bytes;
            done <= done;
            count <= count;
            if(key_exp_done==1'b1)
              key_expand_start <= 1'b0;
            else
              key_expand_start <= key_expand_start;
          end 
          sub_bytes:
          begin
            //Add Substitution logic
            for(i=0;i<4;i=i+1)
              word[i] <= SBOX.sub_word(word[i]);
            done<=done;
            state <= shift_row;
            count <= count+1'b1;
            if(key_exp_done==1'b1)
              key_expand_start <= 1'b0;
            else
              key_expand_start <= key_expand_start;
          end
          shift_row:
          begin
            word[0] <= S.shift_row0(word[0],word[1],word[2],word[3]);
            word[1] <= S.shift_row1(word[0],word[1],word[2],word[3]);
            word[2] <= S.shift_row2(word[0],word[1],word[2],word[3]); 
            word[3] <= S.shift_row3(word[0],word[1],word[2],word[3]);
            if(count == Rounds_P)
              state <= add_round_key;
            else
              state <= mix_column;
            done <= done;
            if(key_exp_done==1'b1)
              key_expand_start <= 1'b0;
            else
              key_expand_start <= key_expand_start;
          end
          mix_column:
          begin
            for(i=0;i<4;i=i+1)
              word[i] <= M.mix_column(word[i]);
            state <= add_round_key;
            done <= done;
            if(key_exp_done==1'b1)
              key_expand_start <= 1'b0;
            else
              key_expand_start <= key_expand_start;
          end
          add_round_key:
          begin
            for(i=0;i<4;i=i+1)
              word[i] <= word[i]^exp_key[(((3-i)<<5)+(count<<7))+:32];
            if(count == Rounds_P)
              state <= finish;
            else
              state <= sub_bytes; 
            done <= done;
            count <= count;
            if(key_exp_done==1'b1)
              key_expand_start <= 1'b0;
            else
              key_expand_start <= key_expand_start;
          end
          finish:
          begin
            for(i=0;i<4;i=i+1)
              word[i] <= word[i];
            done <= 1'b1;
            key_expand_start <= 1'b0;
          end
          default:
          begin
            for(i=0;i<4;i=i+1)
              word[i] <= word[i];
            state <= init;
            done <= done;
            key_expand_start <= key_expand_start;
            count <= count;
          end
        endcase
      end
  end
  
endmodule 
