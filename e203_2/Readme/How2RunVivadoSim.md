本文用于介绍如何在 Vivado 上进行单精度浮点运算的功能仿真。作者借助 Whetstone 实现该操作。编译器使用 Nuclei Studio IDE。

在路径```./Software_Cde/e203Whetstone_test/application```中找到文件 *whets.c*，打开并将里面的几个变量修改成如下代码所示：
```
count = 1;
x100 = 50;
xtra = 1;
```
然后使用编译器生成相应的 *.verilog* 文件。

接着打开 Vivado 工程 "e203_2"，置顶文件 *tb_top.v*。在文件中找到第 277~280 行，代码如下：
```
//$readmemh({testcase, "E:/NucleiStudio_Workspace/e203Whetstone_test/Debug/e203Whetstone_test.verilog"}, itcm_mem);
//$readmemh({testcase, "E:/NucleiStudio_Workspace/e203Dhrystone_test/Debug/e203Dhrystone_test.verilog"}, itcm_mem);
//$readmemh({testcase, "E:/NucleiStudio_Workspace/e203Coremark_test/Debug/e203Coremark_test.verilog"}, itcm_mem);
$readmemh({testcase, "E:/NucleiStudio_Workspace/e203_fls_test/Debug/e203_fls_test.verilog"}, itcm_mem);
```
以上代码包含了三个 Benchmark 的 *.verilog* 文件。其中 *e203_fls_test.verilog* 文件为作者自己 Debug 时用的文件，在这里可以删去。在剩下的三行代码中，选择想要用于功能测试的文件，取消注释，然后添加相应 *.verilog* 即可进行行为级别的仿真。