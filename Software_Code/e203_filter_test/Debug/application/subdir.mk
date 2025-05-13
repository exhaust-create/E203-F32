################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../application/main.c \
../application/math_helper.c \
../application/ref_conv.c \
../application/ref_helper.c 

OBJS += \
./application/main.o \
./application/math_helper.o \
./application/ref_conv.o \
./application/ref_helper.o 

C_DEPS += \
./application/main.d \
./application/math_helper.d \
./application/ref_conv.d \
./application/ref_helper.d 


# Each subdirectory must supply rules for building sources it contributes
application/%.o: ../application/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-nuclei-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medany -mno-save-restore -O0 -ffunction-sections -fdata-sections -fno-common --specs=nano.specs --specs=nosys.specs -u _printf_float  -g -D__IDE_RV_CORE=e203 -DSOC_HBIRD -DDOWNLOAD_MODE=DOWNLOAD_MODE_ILM -DDOWNLOAD_MODE_STRING=\"ILM\" -DBOARD_DDR200T -I"E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\NMSIS\Core\Include" -I"E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\NMSIS\DSP\Include" -I"E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\NMSIS\NN\Include" -I"E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\SoC\hbirdv2\Common\Include" -I"E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\SoC\hbirdv2\Board\ddr200t\Include" -I"E:\NucleiStudio_Workspace\e203_filter_test\application" -std=gnu11 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


