import cv2
import numpy as np
import matplotlib.pyplot as plt

img = cv2.imread('./test.png',0)
img_fft = np.fft.fft2(img)
img_fftshift = np.fft.fftshift(img_fft)
mag = 20*np.log(np.abs(img_fftshift))
plt.imshow(mag,cmap='gray')
plt.title('noisy_dog_cifar10 Centered Spectrum')
plt.show()