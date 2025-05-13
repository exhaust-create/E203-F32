################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../application/cpuidc.c \
../application/whets.c 

OBJS += \
./application/cpuidc.o \
./application/whets.o 

C_DEPS += \
./application/cpuidc.d \
./application/whets.d 


# Each subdirectory must supply rules for building sources it contributes
application/%.o: ../application/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-nuclei-elf-gcc -march=rv32imafc -mabi=ilp32f -mcmodel=medany -mno-save-restore -funroll-loops -Ofast -ffunction-sections -fdata-sections -fno-common -fsingle-precision-constant --specs=nano.specs --specs=nosys.specs -u _printf_float  -g -D__IDE_RV_CORE=e203 -DSOC_HBIRD -DDOWNLOAD_MODE=DOWNLOAD_MODE_ILM -DDOWNLOAD_MODE_STRING=\"ILM\" -DBOARD_DDR200T -I"E:\NucleiStudio_Workspace\e203Whetstone_test\hbird_sdk\NMSIS\Core\Include" -I"E:\NucleiStudio_Workspace\e203Whetstone_test\hbird_sdk\SoC\hbirdv2\Common\Include" -I"E:\NucleiStudio_Workspace\e203Whetstone_test\hbird_sdk\SoC\hbirdv2\Board\ddr200t\Include" -I"E:\NucleiStudio_Workspace\e203Whetstone_test\application" -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


