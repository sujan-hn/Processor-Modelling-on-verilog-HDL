# Processor-Modelling-on-verilog-HDL\
A 16 bit processor is modelled on verilog using Xilinx Vivado tool.\
Processor consists of a 32' bit intruction register(IR[]), which holds the instruction for excexuting programs, and 32 general purpose registers each of 16'bits, for storing and performing operations\
The processor consists of ALU unit which performs all logical and arithmatic functions\
The instructions are stored in Inst_memory and the IR[] value gets updated everytime by the program counter\
The "instruction2.mem" file uploaded on the repo implies to perform a function to increment and decrement the value of registers R1 and R0 values repectively, by utilizing the jump instructions.\
****INSTRUCTION****\
MOV R0,#10\
MOV R1,#0\
ADD R1,#1\
SUB R0,1\
JNZ\
STOREREG DATAMEM[0],R1\
HALT


