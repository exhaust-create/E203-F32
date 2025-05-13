'''
Convert a picture(32,32,RGB) to .txt
'''

import cv2     # h, w, c
import numpy
import matplotlib.pyplot as plt

img = cv2.imread("./images/dog2_web.jpg",1)
img = cv2.resize(img,(32,32))    #可以改变图片的大小
print("图像的形状,返回一个图像的(行数,列数,通道数):", img.shape)
print("图像的像素数目:", img.size)
print("图像的数据类型:", img.dtype)


fname = open("./images/dog2_web.txt",'w')

img_1 = img.flatten()
length = img_1.shape[0]

# a = 1
for i in range(length):
    fname.write(str(img_1[i])+',')
fname.close()


cv2.imshow('image',img)
cv2.waitKey(0)
cv2.destroyAllWindows()
