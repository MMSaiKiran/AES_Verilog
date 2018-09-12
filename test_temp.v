`include "main_aes_core.v"

module test();
  reg clock,reset,start;
  reg [127:0] key;
  reg [127:0] plain_text; 
  wire done;
  wire [127:0] cipher_text;
  integer i;
  
  //key_expansion KEY_EXP(.exp_key(expand_key),.done(done),.clock(clock),.reset(reset),.start(start),.key(key));
  aes_core AES(.cipher_text(cipher_text),.done(done),.reset(reset),.clock(clock),.key(key),.plain_text(plain_text));
  
  initial
  begin
    clock = 1'b0;
    forever
    #5 clock = ~clock;
  end
  
  initial
  begin
    key = 128'h000102030405060708090a0b0c0d0e0f;
    plain_text = 128'h00112233445566778899aabbccddeeff;
    #3 reset = 1'b1;
    #10 reset = 1'b0;
    start = 1'b1;
  end
  
  initial
  begin
    $monitor($time,"start:%b key:%h \n done:%b",start,key,done);  
    $monitor($time,"cipher: %h",cipher_text);
    //for(i=0;i<4;i=i+1)
    //begin
      //$display("%h",key[(i<<5)+:31]);
    //end
  end
  always @(AES.exp_key)
  begin
    $display($time,"******************************");
    $display("key[0]: %h",AES.exp_key[127:0]);  
    $display("key[1]: %h",AES.exp_key[255:128]);
    $display("key[2]: %h",AES.exp_key[383:256]);
    $display("key[3]: %h",AES.exp_key[511:384]);
    $display("key[4]: %h",AES.exp_key[639:512]);
    $display("key[5]: %h",AES.exp_key[767:640]);
    $display("key[6]: %h",AES.exp_key[895:768]);
    $display("key[7]: %h",AES.exp_key[1023:896]);
    $display("key[8]: %h",AES.exp_key[1151:1024]);
    $display("key[9]: %h",AES.exp_key[1279:1152]);
    $display("key[10]: %h",AES.exp_key[1407:1280]);
    $display("*********************************");
  end
endmodule 