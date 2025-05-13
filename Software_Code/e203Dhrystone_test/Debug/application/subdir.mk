################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../application/dhry_1.c \
../application/dhry_2.c \
../application/dhry_stubs.c 

OBJS += \
./application/dhry_1.o \
./application/dhry_2.o \
./application/dhry_stubs.o 

C_DEPS += \
./application/dhry_1.d \
./application/dhry_2.d \
./application/dhry_stubs.d 


# Each subdirectory must supply rules for building sources it contributes
application/%.o: ../application/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-nuclei-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medany -mno-save-restore -fno-inline -funroll-loops -Wno-implicit -mexplicit-relocs -fno-builtin-printf -falign-functions=4 -falign-jumps=4 -falign-loops=4 -O2 -ffunction-sections -fdata-sections -fno-common -flto --specs=nano.specs --specs=nosys.specs -u _printf_float  -g -D__IDE_RV_CORE=e203 -DSOC_HBIRD -DDOWNLOAD_MODE=DOWNLOAD_MODE_ILM -DDOWNLOAD_MODE_STRING=\"ILM\" -DBOARD_DDR200T -I"E:\NucleiStudio_Workspace\e203Dhrystone_test\hbird_sdk\NMSIS\Core\Include" -I"E:\NucleiStudio_Workspace\e203Dhrystone_test\hbird_sdk\SoC\hbirdv2\Common\Include" -I"E:\NucleiStudio_Workspace\e203Dhrystone_test\hbird_sdk\SoC\hbirdv2\Board\ddr200t\Include" -I"E:\NucleiStudio_Workspace\e203Dhrystone_test\application" -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


