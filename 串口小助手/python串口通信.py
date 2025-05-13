import serial,threading,time
import numpy as np
import os
import cv2

# Global variables
is_a = 0
is_s = 0
start_print = 0
data_final = ''

class SerThread():
    def __init__(self,portx):
        # 初始化串口
        self.my_serial=serial.Serial()
        self.my_serial.port=portx
        self.my_serial.baudrate=115200
        self.my_serial.timeout=1
        fname=time.strftime('%Y%m%d')+".txt"   # blog名称为当前时间
        self.rfname='r'+fname   # 接收blog名称
        self.sfname='s'+fname   # 发送blog名称
        self.waitEnd=None   # 设置线程事件变量
        self.alive=False    # 设置条件变量

    def start(self):
        # 打开串口并创建blog文件
        self.my_serial.open()   # 打开串口
        self.rfile=open(self.rfname,'w')    # 创建接收文件
        self.sfile=open(self.sfname,'w')    # 创建发送文件

        if self.my_serial.isOpen():
            self.waitEnd=threading.Event()  # 将线程事件赋值给变量
            self.alive=True # 改变条件变量值

            self.thread_read=threading.Thread(target=self.Reader)   # 创建一个读取串口数据的线程
            self.thread_read.setDaemon(True)    # 调用线程同时结束的函数

            self.thread_send=threading.Thread(target=self.Sender)   # 创建一个发送串口数据的线程
            self.thread_send.setDaemon(True)    # 调用线程同时结束的函数

            self.thread_read.start()    # 启动读数据线程
            self.thread_send.start()    # 启动写数据线程
            return True # 如果串口打开了，就返回True
        else:
            return False    #如果串口未打开，就返回False


    def Reader(self):
        global is_a, is_s, start_print, data_final
        while self.alive:   # 当条件变量为True时执行
            try:
#                time.sleep(0.1)    # 此处最好设置一个暂停时间，为了上串口发过来的数据缓存到接收缓存区
                '''
                n=self.my_serial.inWaiting()    # 将接收缓存区数据字节数保存在变量n中
                data=''
                if n:
                    data=self.my_serial.read(n).decode('iso-8859-1')   # 读取接收缓存区的数据并解码
#                    print(data.strip()) # 将接收到的数据打印出来
#                    print('recv'+' '+time.strftime('%Y-%m-%d %X')+' '+data.strip()) # 将接收到的数据打印出来
                    print(data.strip(),file=self.rfile)   # 将打印的内容写入到文件中
                    if len(data)==1 and ord(data[len(data)-1])==113:    # 根据输入的'q'来退出程序
                        break
                '''
                # 估计 python 的串口读取操作是：在 Buffer 中读取多少数据，in_waiting 就减多少。
                # 所以不用担心 n < in_waiting 时，剩下没有被读取的数据要怎么处理
                n=6147  
                data = ''
                if self.my_serial.in_waiting:
                    data=self.my_serial.read(n).decode('iso-8859-1')   # 读取接收缓存区的数据并解码
                    where_record_start = data.find('aaa') # The first occurrence of the substring 'aaa' in "data"
                    where_record_end = data.find('sss') # The first occurrence of the substring 'sss' in "data"
                    where_print_start = data.find('CNN') # The first occurrence of the substring 'CNN' in "data"
                    where_print_end = data.find('End')
                    # 如果找到了 'aaa'，说明开始传输图像数据，此时就要将'aaa'后面的数据全部保存
                    if where_record_start != -1:
                        is_a = 1
                        data_final = data[(where_record_start+3):]
                        print('recv'+' '+time.strftime('%Y-%m-%d %X')+' '+data[:where_record_start]) # 将接收到的数据打印出来
                    # 如果没找到 'aaa'
                    else:
                        # 但前面出现过 'aaa'
                        if is_a == 1:
                            # 并且找到了 'sss'，则把 'sss' 前面的数据保存下来
                            if where_record_end != -1:
                                is_s = 1
                                data_final += data[:where_record_end]   # 追加字符
                            # 并且找不到 'sss', 就把全部数据保存下来
                            else:
                                data_final += data
                        # 如果没出现过 'aaa', 则 is_s 一定为 0
                        else:
                            is_s = 0
                    # 如果 'aaa' 和 'sss' 都出现了，则把图像数据全部写在文件中
                    if is_a==1 and is_s==1:
                        is_a, is_s = 0,0
                        print('data_final len = ',len(data_final.strip()))
                        print(data_final.strip(),file=self.rfile)   # 将打印的内容写入到文件中
                        
                        # 生成图片
                        img_data = np.fromstring(data_final.strip()[:-1],dtype=np.uint8,sep=',')
                        img = np.array(img_data).reshape(32,32,3)
                        cv2.imwrite("test.png", img)
                        
                        data_final = ''
                    # 如果找到了 'CNN'
                    if where_print_start != -1:
                        start_print = 1
                        print('recv'+' '+time.strftime('%Y-%m-%d %X')+' '+data[where_print_start:]) # 将接收到的数据打印出来
                    else:
                        # 如果没找到 'CNN' 但之前出现过 'CNN'
                        if start_print == 1:
                            print('recv'+' '+time.strftime('%Y-%m-%d %X')+' '+data) # 将接收到的数据打印出来
                    if where_print_end != -1:
                        start_print = 0

            except Exception as ex:
                print(ex)

        self.waitEnd.set()  # 改变线程事件状态为True，即唤醒后面的程序
        self.alive=False    # 改变条件量为False

    def Sender(self):
        while self.alive:
            try:
                start_send = input('是否发送图片数据？--0:否--1:是--2:中止程序\r\n')
                if start_send == '1':
                    picture = np.genfromtxt(fname="./images/noisy_dog_cifar10.txt",dtype=np.uint8,delimiter=',')[:-1]
                    self.my_serial.write(picture)       # 不要用循环一个个发送！
                elif start_send == '2':
                    os._exit(0)
                else:
                    print("拒绝发送")
            except Exception as ex:
                print(ex)
        # 此两行代码是不用写的，因为前面我们用了self.thread_send.setDaemon(True)代码，
        # 其只要一个线程结束，另的线程也会结束
        # self.waitEnd.set()
        # self.alive=False


    def waiting(self):
        # 等待event停止标志
        if not self.waitEnd is None:
            self.waitEnd.wait() # 改变线程事件状态为False，使线程阻止后续程序执行

    # 关闭串口、保存文件
    def stop(self):
        self.alive=False
        if self.my_serial.isOpen():
            self.my_serial.close()
        self.rfile.close()
        self.sfile.close()

if __name__ == '__main__':
    ser=SerThread('COM4')
    try:
        if ser.start():
            ser.waiting()
            ser.stop()

        else:
            pass

    except Exception as ex:
        print(ex)

    if ser.alive:
        ser.stop()

    print('End OK.')
    del ser
        
        