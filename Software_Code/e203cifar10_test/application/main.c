#include <stdint.h>
#include <stdio.h>

#include "hbird_sdk_soc.h"
#include "ref_conv.h"
#include "riscv_math.h"

#include "riscv_nnexamples_cifar10_parameter.h"
#include "riscv_nnexamples_cifar10_weights.h"
#include "riscv_nnexamples_cifar10_inputs.h"
#include "image_data.h"

#include "riscv_nnfunctions.h"

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


// include the input and weights

static q7_t conv1_wt[CONV1_IM_CH * CONV1_KER_DIM * CONV1_KER_DIM * CONV1_OUT_CH] = CONV1_WT;
static q7_t conv1_bias[CONV1_OUT_CH] = CONV1_BIAS;

static q7_t conv2_wt[CONV2_IM_CH * CONV2_KER_DIM * CONV2_KER_DIM * CONV2_OUT_CH] = CONV2_WT;
static q7_t conv2_bias[CONV2_OUT_CH] = CONV2_BIAS;

static q7_t conv3_wt[CONV3_IM_CH * CONV3_KER_DIM * CONV3_KER_DIM * CONV3_OUT_CH] = CONV3_WT;
static q7_t conv3_bias[CONV3_OUT_CH] = CONV3_BIAS;

static q7_t ip1_wt[IP1_DIM * IP1_OUT] = IP1_WT;
static q7_t ip1_bias[IP1_OUT] = IP1_BIAS;

/* Here the image_data should be the raw uint8 type RGB image in [RGB, RGB, RGB ... RGB] format */
#define _DECLARE_IMAGE(img) static uint8_t image_data[CONV1_IM_CH * CONV1_IM_DIM * CONV1_IM_DIM] = IMG_DATA_##img; \
                           const char *image_name = #img;
#define DECLARE_IMAGE(img) _DECLARE_IMAGE(img)
// Change the DECLARE_IMAGE(imgno) to select different images
// img could be airplane, automobile, bird, cat, deer, dog, horse, ship, truck
// no could be 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
// eg. Use deer1:
// DECLARE_IMAGE(deer1);
// eg. Use dog10:
// DECLARE_IMAGE(dog10);
#ifndef TEST_IMAGE
#define TEST_IMAGE cat_web
#endif
DECLARE_IMAGE(TEST_IMAGE);

q7_t      output_data[IP1_OUT];

//vector buffer: max(im2col buffer,average pool buffer, fully connected buffer)
q7_t      col_buffer[2 * 5 * 5 * 32 * 2];

q7_t      scratch_buffer[32 * 32 * 10 * 4];

const char* cifar10_label[] = {"Plane", "Car", "Bird", "Cat", "Deer", "Dog", "Frog", "Horse", "Ship", "Truck"};

//BENCH_DECLARE_VAR();

int main()
{
  #ifdef RTE_Compiler_EventRecorder
  EventRecorderInitialize (EventRecordAll, 1);  // initialize and start Event Recorder
  #endif

  printf("start execution cnn to classify image %s\n", image_name);
  /* start the execution */

  q7_t     *img_buffer1 = scratch_buffer;
  q7_t     *img_buffer2 = img_buffer1 + 32 * 32 * 32;

//  BENCH_INIT();

  /* input pre-processing */
  BENCH_START(preprocess);
  int mean_data[3] = INPUT_MEAN_SHIFT;
  unsigned int scale_data[3] = INPUT_RIGHT_SHIFT;
  for (int i=0;i<32*32*3; i+=3) {
    img_buffer2[i] =   (q7_t)__SSAT( ((((int)image_data[i]   - mean_data[0])<<7) + (0x1<<(scale_data[0]-1)))
                             >> scale_data[0], 8);
    img_buffer2[i+1] = (q7_t)__SSAT( ((((int)image_data[i+1] - mean_data[1])<<7) + (0x1<<(scale_data[1]-1)))
                             >> scale_data[1], 8);
    img_buffer2[i+2] = (q7_t)__SSAT( ((((int)image_data[i+2] - mean_data[2])<<7) + (0x1<<(scale_data[2]-1)))
                             >> scale_data[2], 8);
  }
  BENCH_END(preprocess);

  BENCH_START(riscv_convolve_HWC_q7_RGB);
  // conv1 img_buffer2 -> img_buffer1
  riscv_convolve_HWC_q7_RGB(img_buffer2, CONV1_IM_DIM, CONV1_IM_CH, conv1_wt, CONV1_OUT_CH, CONV1_KER_DIM, CONV1_PADDING,
                          CONV1_STRIDE, conv1_bias, CONV1_BIAS_LSHIFT, CONV1_OUT_RSHIFT, img_buffer1, CONV1_OUT_DIM,
                          (q15_t *) col_buffer, NULL);
  BENCH_END(riscv_convolve_HWC_q7_RGB);

  BENCH_START(riscv_relu_q7);
  riscv_relu_q7(img_buffer1, CONV1_OUT_DIM * CONV1_OUT_DIM * CONV1_OUT_CH);
  BENCH_END(riscv_relu_q7);

  BENCH_START(riscv_maxpool_q7_HWC);
  // pool1 img_buffer1 -> img_buffer2
  riscv_maxpool_q7_HWC(img_buffer1, CONV1_OUT_DIM, CONV1_OUT_CH, POOL1_KER_DIM,
                     POOL1_PADDING, POOL1_STRIDE, POOL1_OUT_DIM, NULL, img_buffer2);
  BENCH_END(riscv_maxpool_q7_HWC);

  BENCH_START(riscv_convolve_HWC_q7_fast);
  // conv2 img_buffer2 -> img_buffer1
  riscv_convolve_HWC_q7_fast(img_buffer2, CONV2_IM_DIM, CONV2_IM_CH, conv2_wt, CONV2_OUT_CH, CONV2_KER_DIM,
                           CONV2_PADDING, CONV2_STRIDE, conv2_bias, CONV2_BIAS_LSHIFT, CONV2_OUT_RSHIFT, img_buffer1,
                           CONV2_OUT_DIM, (q15_t *) col_buffer, NULL);
  BENCH_END(riscv_convolve_HWC_q7_fast);

  BENCH_START(riscv_relu_q7);
  riscv_relu_q7(img_buffer1, CONV2_OUT_DIM * CONV2_OUT_DIM * CONV2_OUT_CH);
  BENCH_END(riscv_relu_q7);

  BENCH_START(riscv_maxpool_q7_HWC);
  // pool2 img_buffer1 -> img_buffer2
  riscv_maxpool_q7_HWC(img_buffer1, CONV2_OUT_DIM, CONV2_OUT_CH, POOL2_KER_DIM,
                     POOL2_PADDING, POOL2_STRIDE, POOL2_OUT_DIM, col_buffer, img_buffer2);
  BENCH_END(riscv_maxpool_q7_HWC);

  BENCH_START(riscv_convolve_HWC_q7_fast);
  // conv3 img_buffer2 -> img_buffer1
  riscv_convolve_HWC_q7_fast(img_buffer2, CONV3_IM_DIM, CONV3_IM_CH, conv3_wt, CONV3_OUT_CH, CONV3_KER_DIM,
                           CONV3_PADDING, CONV3_STRIDE, conv3_bias, CONV3_BIAS_LSHIFT, CONV3_OUT_RSHIFT, img_buffer1,
                           CONV3_OUT_DIM, (q15_t *) col_buffer, NULL);
  BENCH_END(riscv_convolve_HWC_q7_fast);

  BENCH_START(riscv_relu_q7);
  riscv_relu_q7(img_buffer1, CONV3_OUT_DIM * CONV3_OUT_DIM * CONV3_OUT_CH);
  BENCH_END(riscv_relu_q7);

  BENCH_START(riscv_maxpool_q7_HWC);
  // pool3 img_buffer-> img_buffer2
  riscv_maxpool_q7_HWC(img_buffer1, CONV3_OUT_DIM, CONV3_OUT_CH, POOL3_KER_DIM,
                     POOL3_PADDING, POOL3_STRIDE, POOL3_OUT_DIM, col_buffer, img_buffer2);
  BENCH_END(riscv_maxpool_q7_HWC);

  BENCH_START(riscv_fully_connected_q7_opt);
  riscv_fully_connected_q7_opt(img_buffer2, ip1_wt, IP1_DIM, IP1_OUT, IP1_BIAS_LSHIFT, IP1_OUT_RSHIFT, ip1_bias,
                             output_data, (q15_t *) img_buffer1);
  BENCH_END(riscv_fully_connected_q7_opt);

  BENCH_START(riscv_softmax_q7);
  riscv_softmax_q7(output_data, 10, output_data);
  BENCH_END(riscv_softmax_q7);

  float confidence = 0.0;
  for (int i = 0; i < 10; i++) {
      confidence = (output_data[i]/127.0)*100;
      printf("label %d: %d, %s, %.2f%%\n", \
              i, output_data[i], cifar10_label[i], confidence);
  }
  return 0;
}
