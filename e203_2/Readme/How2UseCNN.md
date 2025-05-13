本文介绍如何使用本团队设计的 CNN 识别图片。

## 一、操作步骤
找到以下文件并用 Nuclei Studio IDE 打开：
```
Software_Code:
|-- e203cifar10_test:
|---- e203cifar10_test.nuproject
```
对该工程进行编译后，即可下载到 E203 F 上。

## 二、代码讲解
在工程中找到如下文件：
```
application:
|-- image_data.h
|-- main.c
|-- riscv_nnexamples_cifar10_inputs.h
```
其中文件 *image_data.h* 包含了所有 cifar10 的测试集的图像数据。文件 *riscv_nnexamples_cifar10_inputs.h* 存在着本团队自己找的猫猫图片的 RGB 数据。
文件 *main.c* 含有图像识别算法的代码。

在文件 *main.c* 找到如下代码：
```
#define TEST_IMAGE cat_web
```
其中 ”cat_web“ 就是想要识别的图像的名字，例如图像在文件 *image_data.h* 或 *riscv_nnexamples_cifar10_inputs.h* 中的名字叫 ```IMG_DATA_cat_web```，则上述代码中就写入```cat_web```。

## 三、python 生成 32*32*3 图像数据
找到以下 python 文件:
```
Software_Code:
|-- read_image_4_cifar10:
|---- ReadImage.py
```
运行该文件，就能将非 32*32*3 的图片转换成 32*32*3 的图片，并且输出一维图像数据，格式为 ”R, G, B, R, G, B, ...“。