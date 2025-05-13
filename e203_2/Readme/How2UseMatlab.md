作者借助 Matlab 实现 E203 F 的串口通信与滤波。

## 一、Matlab 操作

在如下路径中找到文件 *matlab_serial.m* ：
```
matlab串口小助手:
|-- matlab_serial.m
```
用 Matlab 打开文件，找到如下代码;
```
S = serialport("COM4",115200,"Parity","none","DataBits",8,"StopBits",1);
```
作者的电脑连接串口的端口为 ```“COM4”```，因此上述代码的第一个参数为```“COM4”```。若上位机连接串口的端口号不是 ```“COM4”```，则要修改成相应的端口号。

第二个参数为波特率，这里设置了```115200```。校验位选择```"none"```。

## 二、Nuclei Studio 操作
找到以下文件并用 Nuclei Studio IDE 打开：
```
Software_Code:
|-- e203_filter_test:
|---- e203_filter_test.nuproject
```
对该工程进行编译后，即可下载到 E203 F 上。

## 三、实验结果

若此时上位机已经和开发板相连，以上操作都完成了，则可以直接点击 Matlab 的“运行”。按照经验，需要点击至少两次“运行”才会有结果打印出来，打印结果的其中一部分如下图:
![IIR整数指令滤波结果0-4](./images/IIR%E6%95%B4%E6%95%B0%E6%8C%87%E4%BB%A4%E6%BB%A4%E6%B3%A2%E7%BB%93%E6%9E%9C0-4.png)