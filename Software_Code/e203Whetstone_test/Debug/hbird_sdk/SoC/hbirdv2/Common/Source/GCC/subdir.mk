################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_UPPER_SRCS += \
../hbird_sdk/SoC/hbirdv2/Common/Source/GCC/intexc_hbirdv2.S \
../hbird_sdk/SoC/hbirdv2/Common/Source/GCC/startup_hbirdv2.S 

OBJS += \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/intexc_hbirdv2.o \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/startup_hbirdv2.o 

S_UPPER_DEPS += \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/intexc_hbirdv2.d \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/startup_hbirdv2.d 


# Each subdirectory must supply rules for building sources it contributes
hbird_sdk/SoC/hbirdv2/Common/Source/GCC/%.o: ../hbird_sdk/SoC/hbirdv2/Common/Source/GCC/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	riscv-nuclei-elf-gcc -march=rv32imafc -mabi=ilp32f -mcmodel=medany -mno-save-restore -funroll-loops -Ofast -ffunction-sections -fdata-sections -fno-common -fsingle-precision-constant --specs=nano.specs --specs=nosys.specs -u _printf_float  -g -x assembler-with-cpp -D__IDE_RV_CORE=e203 -DSOC_HBIRD -DDOWNLOAD_MODE=DOWNLOAD_MODE_ILM -DDOWNLOAD_MODE_STRING=\"ILM\" -DBOARD_DDR200T -I"E:\NucleiStudio_Workspace\e203Whetstone_test\hbird_sdk\NMSIS\Core\Include" -I"E:\NucleiStudio_Workspace\e203Whetstone_test\hbird_sdk\SoC\hbirdv2\Common\Include" -I"E:\NucleiStudio_Workspace\e203Whetstone_test\hbird_sdk\SoC\hbirdv2\Board\ddr200t\Include" -I"E:\NucleiStudio_Workspace\e203Whetstone_test\application" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


