
#ifndef MY_ALU_DRIVER_H   
#define MY_ALU_DRIVER_H

#include "xil_types.h"
#include "xil_io.h"
#include "xparameters.h"

#define ALU_BASE XPAR_ZAMFP_IP_CORE_0_BASEADDR


// pierwszą liczba
#define REG_OFFSET_OPERAND_A    0x00 

// drugą liczba
#define REG_OFFSET_OPERAND_B    0x04 

// operacja
#define REG_OFFSET_OPCODE       0x08 

// wynik 
#define REG_OFFSET_RESULT       0x0C 

// wyboru rejestru 
#define REG_OFFSET_MEM_SEL      0x10 

#define OP_ADD      0  
#define OP_AND      1  
#define OP_XOR      2  
#define OP_LOAD_A   3  
#define OP_M_PLUS   4  
#define OP_M_MINUS  5  
#define OP_MR       6  
#define OP_MC       7  


void ALU_SetA(u32 val);

void ALU_SetB(u32 val);

void ALU_SetOpcode(u32 opcode);

u32  ALU_GetResult(void);

void ALU_SetMemSel(u32 reg_index);

void ALU_WriteSpecificReg(int reg_index, u32 val);

u32  ALU_ReadSpecificReg(int reg_index);

#endif 