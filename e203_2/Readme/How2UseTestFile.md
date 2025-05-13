*TestFile* 文件夹内的文件被用于测试单精度浮点算术单元 FALU 。其中用于生成随机数的 python 文件有如下几个：
```
e203_2:
|- Source Code:
|---- TestCasesGeneratorAddition.py
|---- TestCasesGeneratorDivision.py
|---- TestCasesGeneratorFp2Int.py
|---- TestCasesGeneratorInt2Fp.py
|---- TestCasesGeneratorMultiplication.py
|---- TestCasesGeneratorSqrt.py
|---- TestCasesGeneratorSubtraction.py
|---- TestCasesGeneratorUSInt2Fp.py
```
可以从名字中看到各文件是用于测试什么的。例如 *TestCasesGeneratorAddition.py* 就是用于生成测试单精度浮点加法的随机数。

在以上 python 文件中，会存在两个变量 ```span```和```iteration```。其中```span```为需要生成的随机数的最大绝对值，```iteration```为需要生成的随机数个数。

在 Vivado 工程当中测试 FALU 的功能，首先得把文件 *FP_ALU_tb_v2.V* 设为顶层，然后找到 73~99 行。这里写上了每个操作相对应的测试数据的路径，例如以下代码：
```
 if (div_en) begin    // Div Test File
    $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorDivision", testVector);
    mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsDivision_Ver2.txt");
end
```

在使用随机数测试时，修改相应随机数文件和想要生成测试结果文件的路径，即可在 Vivado 上进行行为级别的仿真。

当需要修改测试数据个数时，需要同时修改数据生成文件的 ```iteration```和 *FP_ALU_tb_v2.V* 的 ```N_TESTS```变量，且数值要相同。