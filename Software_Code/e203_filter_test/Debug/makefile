################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include hbird_sdk/SoC/hbirdv2/Common/Source/Stubs/subdir.mk
-include hbird_sdk/SoC/hbirdv2/Common/Source/GCC/subdir.mk
-include hbird_sdk/SoC/hbirdv2/Common/Source/Drivers/subdir.mk
-include hbird_sdk/SoC/hbirdv2/Common/Source/subdir.mk
-include application/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_FLASH += \
e203_filter_test.hex \

SECONDARY_LIST += \
e203_filter_test.lst \

SECONDARY_SIZE += \
e203_filter_test.siz \


# All Target
all: e203_filter_test.elf secondary-outputs

# Tool invocations
e203_filter_test.elf: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C++ Linker'
	riscv-nuclei-elf-g++ -march=rv32imac -mabi=ilp32 -mcmodel=medany -mno-save-restore -O0 -ffunction-sections -fdata-sections -fno-common --specs=nano.specs --specs=nosys.specs -u _printf_float  -g -T "E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\SoC\hbirdv2\Board\ddr200t\Source\GCC\gcc_hbirdv2_ilm.ld" -nostartfiles -Xlinker --gc-sections -L"E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\NMSIS\Library\DSP\GCC" -L"E:\NucleiStudio_Workspace\e203_filter_test\hbird_sdk\NMSIS\Library\NN\GCC" -Wl,-Map,"e203_filter_test.map" -u _isatty -u _write -u _sbrk -u _read -u _close -u _fstat -u _lseek -o "e203_filter_test.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

e203_filter_test.hex: e203_filter_test.elf
	@echo 'Invoking: GNU RISC-V Cross Create Flash Image'
	riscv-nuclei-elf-objcopy -O ihex "e203_filter_test.elf"  "e203_filter_test.hex"
	@echo 'Finished building: $@'
	@echo ' '

e203_filter_test.lst: e203_filter_test.elf
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv-nuclei-elf-objdump --source --all-headers --demangle --line-numbers --wide "e203_filter_test.elf" > "e203_filter_test.lst"
	@echo 'Finished building: $@'
	@echo ' '

e203_filter_test.siz: e203_filter_test.elf
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv-nuclei-elf-size --format=berkeley "e203_filter_test.elf"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(CC_DEPS)$(C++_DEPS)$(OBJS)$(C_UPPER_DEPS)$(CXX_DEPS)$(SECONDARY_FLASH)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS)$(CPP_DEPS) e203_filter_test.elf
	-@echo ' '

secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

.PHONY: all clean dependents

-include ../makefile.targets
