// See LICENSE for license details.
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include <math.h>
#include <string.h>
#include "riscv_math.h"

/**********BENCH***********/
static uint64_t enter_cycle;
static uint64_t exit_cycle;
static uint64_t start_cycle;
static uint64_t end_cycle;
static uint64_t cycle;
static uint32_t bench_ercd;

#define BENCH_INIT enter_cycle = __get_rv_cycle();

#define BENCH_START(func)                                                      \
    start_cycle = __get_rv_cycle();                                            \
    bench_ercd = 0;
#define BENCH_END(func)                                                        \
    end_cycle = __get_rv_cycle();                                              \
    cycle = end_cycle - start_cycle;                                           \
    printf("CSV, %s, %lu\n", #func, cycle);

#define BENCH_ERROR(func) bench_ercd = 1;
#define BENCH_STATUS(func)                                                     \
    if (bench_ercd) {                                                          \
        printf("ERROR, %s\n", #func);                                          \
    } else {                                                                   \
        printf("SUCCESS, %s\n", #func);                                        \
    }

#define BENCH_FINISH()                                                         \
    exit_cycle = __get_rv_cycle();                                             \
    cycle = exit_cycle - enter_cycle;                                          \
    printf("CSV, BENCH END, %lu\n", cycle);


#define s_len 40 			//Max uart rx_data lenth: 40 bytes
#define f_len s_len/4		//样点数：s_len/4
#define temp_s_len 126		//缓冲区最大数量，包含帧头和帧尾
/*************************************************/

/****************For Filter***************************/
#define block_size s_len/4	//等于f_len
#define filter1_stage 2

// 设定滤波器参数。滤波器为桥型自回归平均滤波器。
float32_t filter1_pState[filter1_stage+block_size];
float32_t filter1_pkCoeffs[filter1_stage] = {0.3090170026,0.1958157122};
float32_t filter1_pvCoeffs[filter1_stage+1] = {0.1175339967*1.1,0.6380622387*1.1,0.3913357854*1.1};
float32_t filter_res[s_len/4];

uint8_t uart0_finish = 0;
uint8_t check_s = 0;
uint8_t temp_s[temp_s_len];
static uint8_t s_r_i = 0;	//index
uint8_t s_i;
/**************************************************/

/*****************For UART**************************/
// 10个浮点数
uint8_t s[s_len];
float f[f_len] = {0};		//不需要分隔符，每32位就分割出来
float temp_f;

void plic_uart0_handler();

void my_uart_init()
{
	uart_init(UART0,115200);//初始化函数
	uart_config_stopbit(UART0,UART_STOP_BIT_2);//停止位设置
	uart_disable_paritybit(UART0);//校验位设置
	PLIC_Register_IRQ(PLIC_UART0_IRQn,1,plic_uart0_handler);
	uart_enable_rx_th_int(UART0);//中断阈值使能
	uart_set_rx_th(UART0,0);//rx设置中断阈值
	__enable_irq();
}
/***************************************************/

int main(void)
{
	uint8_t t1,t2,t3,t4,t;
	uint32_t tt1,tt2,tt3,tt4,tt;
	my_uart_init();


	//实例化滤波器1
	riscv_iir_lattice_instance_f32 filter1;
	filter1.numStages = filter1_stage;	// 二阶滤波器
	filter1.pState = filter1_pState;
	filter1.pkCoeffs = filter1_pkCoeffs;
	filter1.pvCoeffs = filter1_pvCoeffs;

	while(1){
		if(check_s){
//			printf("check_s = %d\r\n",check_s);
			s_i = s_r_i;
			for(int i=f_len;i>0;i--){
				t1 = temp_s[s_r_i-1];
				t2 = temp_s[s_r_i-2];
				t3 = temp_s[s_r_i-3];
				t4 = temp_s[s_r_i-4];
				tt1 = 0x0000ffff & t1;
				tt2 = 0x0000ffff & t2;
				tt3 = 0x0000ffff & t3;
				tt4 = 0x0000ffff & t4;
				tt = (tt4)|(tt3<<8)|(tt2<<16)|(tt1<<24);
//				printf("tt = %x\r\n",tt);
				f[i-1] = *(float*)&tt;
				s_r_i=s_r_i-4;
			}
			uart0_finish = 1;
			check_s = 0;
		}

		if(uart0_finish){
			for(int i=0;i<s_len/4;i++){
				printf("f[%d] = %f\r\n",i,f[i]);
			}
			// 使用硬件滤波器
			BENCH_START(riscv_iir_lattice_f32);
			riscv_iir_lattice_f32(&filter1,f,filter_res,block_size);
			BENCH_END(riscv_iir_lattice_f32);
			for(int i=0;i<s_len/4;i++){
//				printf("%f\r\n",filter_res[i]);
				printf("filter_res[%d] = %f\r\n",i,filter_res[i]);
			}
			uart0_finish = 0;
		}
	}
    return 0;
}

// 中断服务函数
// 自动清零中断标志位
// 不在这里判断数据包是否有效，这里只管塞满
void plic_uart0_handler()
{
	uint8_t c;
	static uint8_t count = 0;

	c = uart_read(UART0);
//	printf("c = %d \r\n",c);

	temp_s[s_r_i] = c;
//	printf("temp_s[%d] = %d\r\n",s_r_i,temp_s[s_r_i]);
	s_r_i++;
//	printf("s_r_i = %d \r\n",s_r_i);

	//当收集到s_len个uint8数据时，就开始倒序装进f当中
	if(s_r_i == s_len)
		check_s = 1;
}
