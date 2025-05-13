- Version 2.0

本文将介绍如何使用 python 文件辅助完成图像滤波和图像识别。
1. 首先将工程 e203_2 烧到 FPGA 上，然后在 FPGA 上运行软件工程：e203_filter_test。
2. 使用下面的 python 文件生成 ```32*32*3 ``` 大小的1维图片数据:
   ```
   ./ReadImage.py
   ```
   该文件将生成三个图像及相应的```.txt```文件，这三个```.txt```文件分别存放1维的由原图转换成 ```32*32*3``` 大小的图片 RGB 数据、加高斯噪声前的图像 RGB 数据、和加高斯噪声后的图像 RGB 数据，数据格式为：```[BGR,BGR,...,BGR]```。

   若要修改想要生成的图片数据，可以找到以下代码，对着名字修改就行：
   ```
   img = cv2.imread("./images/cat_web.jpg")
   ...
   cv2.imwrite("./images/little_cat_web.png",img)   #生成 32*32*3 图片
   cv2.imwrite("./images/noisy_cat_web.png",noisy_img)  #生成加了高斯噪声的图片
   ...
   fname = open("./images/cat_web.txt",'w')     #生成原图数据
   ...
   fname = open("./images/noisy_cat_web.txt",'w')       #生成加了高斯噪声的数据
   ```
3. 使用如下文件进行串口通信，向 E203 F 发送图片数据：
   ```
   ./python串口通信.py
   ```
   该代码的运行效果为：
   1. 运行后会显示一行字，若输入“1”，则发送完整的图片数据到串口。输入“1”后，需要等待几秒钟，若没有打印出```data_final len = XXX```这一串字符，则再次输入“1”，再等几秒钟，此时必定会打印出 ```data_final len = XXX```这一串字符，说明滤波后的图片数据已经全部被接受。
   2. 接收到的滤波后的图片数据会被放入到一个```.txt```当中，该文件以 "r+当前计算机日期" 命名，并且会在文件“python串口通信.py”的当前路径中生成一张名为“test.png”的图像。
   3. 将图像数据写入```.png```后，就开始接受 E203 F 的图像识别结果。图像识别的结果会直接显示在小黑窗当中，不会被写入任何文件当中。
   
   想要修改发送的图片数据，可以找到以下代码替换文件名即可：
   ```
   #图像数据结尾必须为 ”，“
   picture = np.genfromtxt(fname="./images/noisy_dog_cifar10.txt",dtype=np.uint8,delimiter=',')[:-1]    
   ```
4. 使用如下文件可以查看图像的频谱图：
   ```
   ./img_spectrum.py
   ```