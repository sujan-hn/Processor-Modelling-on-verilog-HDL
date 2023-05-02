`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//instruction register
`define opcode IR[31:27]
`define r_des IR[26:22]
`define r_src1 IR[21:17]
`define imm_mode IR[16]
`define r_src2 IR[15:11]
`define i_src IR[15:0]

// Arithmetic unit -- opcode
`define movmul    5'b00000
`define mov       5'b00001
`define add       5'b00010
`define sub       5'b00011
`define mul       5'b00100  

//LOGICAL UNIT

 
`define or2            5'b00101
`define and2           5'b00110
`define xor2           5'b00111
`define xnor2          5'b01000
`define nand2          5'b01001
`define nor2           5'b01010
`define not1           5'b01011


//STORE REG
`define storereg       5'b01101   //store content of register in data memory
`define storedin       5'b01110   // store content of din bus in data memory
`define senddout       5'b01111   //send data from DM to dout bus
`define sendreg        5'b10001   // send data from DM to register
 
 
 // JUMP INST
`define jump           5'b10010  //jump to address
`define jcarry         5'b10011  //jump if carry
`define jnocarry       5'b10100
`define jsign          5'b10101  //jump if sign
`define jnosign        5'b10110
`define jzero          5'b10111  // jump if zero
`define jnozero        5'b11000

//halt 
`define halt           5'b11001
 
 


 module top(input clk,input rst, input [15:0]d_in, output reg[15:0] d_out);


reg [31:0]inst_mem[15:0];
reg [15:0]data_mem[15:0];


 // condition flags  
reg sign = 0, zero = 0, overflow = 0, carry = 0;
reg [16:0] temp_sum;

//jump flag
reg jmp_flag = 0;
reg stop = 0;
 


reg[31:0] IR;//instruction reg

reg[15:0] GPR[31:0];//general purpose reg

reg[15:0] SGPR;// special gpr for multiplication

reg [31:0] mul_reg;//temporaray reg for MULTIPLICATION






task inst_decode();
begin
case(`opcode)

`movmul:begin
GPR[`r_des] = SGPR;
end

 
 `mov:begin
 if(`imm_mode)
 GPR[`r_des] = `i_src;
 
 else
 GPR[`r_des] = GPR[`r_src1];
 end
 
 `add: begin
 if(`imm_mode)
  GPR[`r_des] = GPR[`r_src1] + `i_src;
  
 else
 GPR[`r_des] = GPR[`r_src1] + GPR[`r_src2];
 end
   
   
`sub:begin
 if(`imm_mode)
 GPR[`r_des] = GPR[`r_src1] - `i_src;
     
 else
 GPR[`r_des] = GPR[`r_src1] - GPR[`r_src2];
 end
      
`mul:begin
 if(`imm_mode)
 mul_reg =  GPR[`r_src1] * `i_src;
     
 else
 mul_reg = GPR[`r_src1] * GPR[`r_src2];
     
 GPR[`r_des]= mul_reg[15:0];
 SGPR = mul_reg[31:16];
 end
     
     
     `or2 : begin
           if(`imm_mode)
             GPR[`r_des]  = GPR[`r_src1] | `i_src;
          else
            GPR[`r_des]   = GPR[`r_src1] | GPR[`r_src2];
     end
     
     
      `and2 : begin
               if(`imm_mode)
                 GPR[`r_des]  = GPR[`r_src1] & `i_src;
              else
                GPR[`r_des]   = GPR[`r_src1] & GPR[`r_src2];
         end
         
         
         
         
          `xor2 : begin
                   if(`imm_mode)
                     GPR[`r_des]  = GPR[`r_src1] ^ `i_src;
                  else
                    GPR[`r_des]   = GPR[`r_src1] ^ GPR[`r_src2];
             end
             
             
          `xnor2 : begin
           if(`imm_mode)
           GPR[`r_des]  = ~(GPR[`r_src1] ^ `i_src);
           else
           GPR[`r_des]   = ~(GPR[`r_src1] ^ GPR[`r_src2]);
           end
                       
          `nand2 : begin
           if(`imm_mode)
           GPR[`r_des]  =~( GPR[`r_src1] & `i_src);
           else
           GPR[`r_des]   = ~(GPR[`r_src1] & GPR[`r_src2]);
           end
                     
          `nor2 : begin
           if(`imm_mode)
           GPR[`r_des]  =~( GPR[`r_src1] | `i_src);
           else
           GPR[`r_des]   = ~(GPR[`r_src1] | GPR[`r_src2]);
           end
                                       
         
         `not1:begin
          if(`imm_mode)
          GPR[`r_des]= ~`i_src;
          else
          GPR[`r_des]=~`r_src1;
          end     
     
         `storedin: begin
          data_mem[`i_src] = d_in;
          end
           
                        
         `storereg: begin
          data_mem[`i_src] = GPR[`r_src1];
          end
                        
        
                        
                        
         `senddout: begin
          d_out  = data_mem[`i_src]; 
          end
                     
                        
          `sendreg: begin
           GPR[`r_des] =  data_mem[`i_src];
           end
     
           `jump: begin
            jmp_flag = 1'b1;
           end
            
           `jcarry: begin
             if(carry == 1'b1)
                jmp_flag = 1'b1;
              else
                jmp_flag = 1'b0; 
           end
            
           `jsign: begin
             if(sign == 1'b1)
                jmp_flag = 1'b1;
              else
                jmp_flag = 1'b0; 
           end
            
           `jzero: begin
             if(zero == 1'b1)
                jmp_flag = 1'b1;
              else
                jmp_flag = 1'b0; 
           end
            
            
           `jnocarry: begin
             if(carry == 1'b0)
                jmp_flag = 1'b1;
              else
                jmp_flag = 1'b0; 
           end
            
           `jnosign: begin
             if(sign == 1'b0)
                jmp_flag = 1'b1;
              else
                jmp_flag = 1'b0; 
           end
            
           `jnozero: begin
             if(zero == 1'b0)
                jmp_flag = 1'b1;
              else
                jmp_flag = 1'b0; 
           end
         
         `halt : begin
           stop = 1'b1;
           end
     endcase
     end
     endtask
     
  
      
     task flag_decode();
     begin
      
     //sign bit
     if(`opcode == `mul)
       sign = SGPR[15];
     else
       sign = GPR[`r_des][15];//MSB of DES_
      
     //carry bit
      
     if(`opcode == `add)
        begin
           if(`imm_mode)
              begin
              temp_sum = GPR[`r_src1] + `i_src;
              carry    = temp_sum[16];               //MSB of temp_sum
              end
           else
              begin
              temp_sum = GPR[`r_src1] + GPR[`r_src2];
              carry    = temp_sum[16]; 
              end   end
        else
         begin
             carry  = 1'b0;
         end
      
    
       
        zero =    ~(|GPR[`r_des]); 
      
      
     //overflow bit(error bit flag)
      
     if(`opcode == `add)
          begin
            if(`imm_mode)
              overflow = ( (~GPR[`r_src1][15] & ~IR[15] & GPR[`r_des][15] ) | (GPR[`r_src1][15] & IR[15] & ~GPR[`r_des][15]) );
            else
              overflow = ( (~GPR[`r_src1][15] & ~GPR[`r_src2][15] & GPR[`r_des][15]) | (GPR[`r_src1][15] & GPR[`r_src2][15] & ~GPR[`r_des][15]));
          end
       else if(`opcode == `sub)
         begin
            if(`imm_mode)
              overflow = ( (~GPR[`r_src1][15] & IR[15] & GPR[`r_des][15] ) | (GPR[`r_src1][15] & ~IR[15] & ~GPR[`r_des][15]) );
            else
              overflow = ( (~GPR[`r_src1][15] & GPR[`r_src2][15] & GPR[`r_des][15]) | (GPR[`r_src1][15] & ~GPR[`r_src2][15] & ~GPR[`r_des][15]));
         end 
       else
          begin
          overflow = 1'b0;
          end
      
     end
     endtask
           
           
     
  initial 
  begin
  $readmemb ("C:/Users/SUJAN/Desktop/instruction_2.mem",inst_mem);
  end 
  
  
  
  
  reg [2:0] count = 0;
  reg[4:0] PC = 0;
  /* 
  always@(posedge clk)
  begin
    if(rst)
     begin
       count <= 0;
       PC    <= 0;
     end
     
     else
     begin
         if(count < 4)
         begin
       count <= count + 1;
         end
     
     
         else
         begin
         count <= 0;
         PC    <= PC + 1;
         end
    end
    
    end

  
  always@(*)
  begin
  if(rst == 1'b1)
  IR = 0;
  else
  begin
  IR = inst_mem[PC];
  inst_decode();
  flag_decode();
  end
  end
  */
  
  //FSM 
  parameter idle = 0, fetch_inst = 1, dec_exec_inst = 2, next_inst = 3, sense_halt = 4, delay_next_inst = 5;
  
  reg [2:0] state = idle;
  reg [2:0]next_state = idle;
  //seq. block
  always@(posedge clk)
  begin
   if(rst)
     state <= idle;
   else
     state<=next_state; 
  end
  
  
  //comb. block
  always@(*)
  begin
    case(state)
      idle: begin
        IR         = 32'h0;
        PC         = 0;
        next_state = fetch_inst;
      end
   
    fetch_inst: 
    begin
      IR          =  inst_mem[PC];   
      next_state  = dec_exec_inst;
    end
    
    dec_exec_inst: begin
      inst_decode();
      flag_decode();
      next_state  = delay_next_inst;   
    end
    
    
    delay_next_inst:
    begin
    if(count < 4)
         next_state  = delay_next_inst;       
       else
         next_state  = next_inst;
    end
    
    next_inst: begin
        next_state = sense_halt;
        if(jmp_flag == 1'b1)
        begin
          PC = `i_src;
          jmp_flag=1'b0;
          end
        else
          PC = PC + 1;
    end
    
    
   sense_halt: begin
      if(stop == 1'b0)
        next_state = fetch_inst;
      else if(rst == 1'b1)
        next_state = idle;
      else
        next_state = sense_halt;
   end
    
    default : next_state = idle;
    
  endcase   
  end
   
   //count value at each state//
   always@(posedge clk)
  begin
  case(state)
   
   idle : begin
      count <= 0;
   end
   
   fetch_inst: begin
     count <= 0;
   end
   
   dec_exec_inst : begin
     count <= 0;    
   end  
   //4 cycles delay
   delay_next_inst: begin
     count  <= count + 1;
   end
   
    next_inst : begin
      count <= 0;
   end
   
    sense_halt : begin
      count <= 0;
   end
   
   default : count <= 0;
   
    
  endcase
  end
   
  



endmodule
