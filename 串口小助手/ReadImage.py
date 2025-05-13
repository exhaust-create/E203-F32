'''
Convert a picture(32,32,RGB) to .txt
'''

import cv2     # h, w, c
import numpy as np
import matplotlib.pyplot as plt

def BGR_to_RGB(cvimg):
    pilimg = cvimg.copy()
    pilimg[:, :, 0] = cvimg[:, :, 2]
    pilimg[:, :, 2] = cvimg[:, :, 0]
    return pilimg

# 添加高斯噪声
# 由于图像数值范围为 0-255 的整数，因此需要归一化和格式转换 
def gauss_noise(img, mean=0, sigma=25):
    
    image = np.array(img / 255, dtype=float)  # 将原始图像的像素值进行归一化
    # 创建一个均值为mean，方差为sigma，呈高斯分布的图像矩阵
    noise = np.random.normal(mean, sigma/255.0, image.shape)
    out = image + noise  # 将噪声和原始图像进行相加得到加噪后的图像
    res_img = np.clip(out, 0.0, 1.0)
    res_img = np.uint8(res_img * 255.0)
    
    return res_img

# 读取图像并转化为 32*32*3 大小
img = cv2.imread("./images/dog_cifar10.png")
img = cv2.resize(img,(32,32))    #可以改变图片的大小

#添加噪声 
noisy_img = gauss_noise(img,mean=0,sigma=10)

'''****************保存图片**************'''
cv2.imwrite("./images/little_dog_cifar10.png",img)
cv2.imwrite("./images/noisy_dog_cifar10.png",noisy_img)
'''*************************************'''

print("图像的形状,返回一个图像的(行数,列数,通道数):", noisy_img.shape)
print("图像的像素数目:", noisy_img.size)
print("图像的数据类型:", noisy_img.dtype)

'''********** 写入原图片 *************************'''
#img = BGR_to_RGB(img)
fname = open("./images/dog_cifar10.txt",'w')
img_1 = img.flatten()       # 降维
length = img_1.shape[0]

for i in range(length):
    fname.write(str(img_1[i])+',')
fname.close()
'''***********************************************'''

'''********** 写入噪声图片 *************************'''
#noisy_img = BGR_to_RGB(noisy_img)
fname = open("./images/noisy_dog_cifar10.txt",'w')
noisy_img_1 = noisy_img.flatten()       # 降维
length = noisy_img_1.shape[0]

for i in range(length):
    fname.write(str(noisy_img_1[i])+',')
fname.close()
'''*********************************************'''

cv2.imshow('image',img)
cv2.imshow('noisy_image',noisy_img)
cv2.waitKey(0)
cv2.destroyAllWindows()

