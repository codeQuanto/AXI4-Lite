#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "alu_driver.h" 


int main()
{
    init_platform();

    xil_printf("\r\nTest start\r\n");
    
    // Zapis do rejestru R5
    xil_printf("Zapis 0x50 do rejestru 5...\r\n");
    ALU_WriteSpecificReg(5, 0x50);
    
    xil_printf("Odczyt rejestrow:\r\n");
    for(int i = 0; i < 16; i++) {
        u32 val = ALU_ReadSpecificReg(i);
        xil_printf("R%-2d = 0x%08X\r\n", i, val);
    }
    xil_printf("Zapis do R5 zakonczony\r\n");
    
    // Proba zapisu do R3 (read-only)
    xil_printf("Proba zapisu 0xDEADBEEF do R3...\r\n");
    ALU_WriteSpecificReg(3, 0xDEADBEEF);
    xil_printf("Odczyt rejestru:\r\n");
    u32 r3_val = ALU_ReadSpecificReg(3);
    xil_printf("R3 = 0x%08X\r\n", r3_val);
    xil_printf("zapis zignorowany\r\n");
    
    // Dodawanie ALU
    xil_printf("Zapis do ALU..\r\n");
    ALU_WriteSpecificReg(0, 0x1E);  // Operand A = 30
    ALU_WriteSpecificReg(1, 0x14);  // Operand B = 20
    ALU_WriteSpecificReg(2, 0x00);  // Opcode = ADD
    
    xil_printf("Odczyt z ALU:\r\n");
    xil_printf("R0 (Operand A) = 0x%08X (30)\r\n", ALU_ReadSpecificReg(0));
    xil_printf("R1 (Operand B) = 0x%08X (20)\r\n", ALU_ReadSpecificReg(1));
    xil_printf("R2 (Opcode)    = 0x%08X (ADD)\r\n", ALU_ReadSpecificReg(2));
    xil_printf("R3 (Result)    = 0x%08X (50)\r\n", ALU_ReadSpecificReg(3));
    xil_printf("Dodawanie zakonczone\r\n");
    
    // M+ do wybranego rejestru (R7)
    ALU_WriteSpecificReg(7, 0x70);  // R7 = 112
    xil_printf("\r\nR7 przed M+: 0x%08X (112)\r\n", ALU_ReadSpecificReg(7));
    
    xil_printf("Zapis..\r\n");
    ALU_WriteSpecificReg(4, 0x07);  // mem_sel = 7 (wybor R7)
    ALU_WriteSpecificReg(2, 0x04);  // Opcode = M_PLUS
    
    xil_printf("R4 (mem_sel) = 0x%08X (wybor R7)\r\n", ALU_ReadSpecificReg(4));
    xil_printf("R2 (Opcode)  = 0x%08X (M_PLUS)\r\n", ALU_ReadSpecificReg(2));
    xil_printf("R3 (Result)  = 0x%08X (50)\r\n", ALU_ReadSpecificReg(3));
    
    xil_printf("Odczyt:\r\n");
    xil_printf("R7 po M+:    0x%08X (162)\r\n", ALU_ReadSpecificReg(7));
    xil_printf("M+ zakonczone\r\n");
    
    xil_printf("\r\nTest koniec\r\n");

    cleanup_platform();
    return 0;
}