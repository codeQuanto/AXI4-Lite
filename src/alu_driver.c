#include "alu_driver.h" 
#include <xparameters.h>

void ALU_SetA(u32 val) {
    Xil_Out32(ALU_BASE + REG_OFFSET_OPERAND_A, val);
}

void ALU_SetB(u32 val) {
    Xil_Out32(ALU_BASE + REG_OFFSET_OPERAND_B, val);
}

void ALU_SetOpcode(u32 opcode) {
    Xil_Out32(ALU_BASE + REG_OFFSET_OPCODE, opcode);
}

u32 ALU_GetResult(void) {
    return Xil_In32(ALU_BASE + REG_OFFSET_RESULT);
}

void ALU_SetMemSel(u32 reg_index) {
    Xil_Out32(ALU_BASE + REG_OFFSET_MEM_SEL, reg_index);
}

void ALU_WriteSpecificReg(int reg_index, u32 val) {
    u32 offset = reg_index * 4;  // Word-aligned addressing
    Xil_Out32(ALU_BASE + offset, val);
}

u32 ALU_ReadSpecificReg(int reg_index) {
    u32 offset = reg_index * 4;  // Word-aligned addressing
    return Xil_In32(ALU_BASE + offset);
}