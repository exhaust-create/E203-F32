import bitstring, random

span = 10000
iteration = 100000

def ieee754(flt):
    b = bitstring.BitArray(float=flt, length=32)
    return b

with open("TestVectorSqrt", "w") as f:

    for i in range(iteration):
        a_src = random.uniform(-span/2, span)
        a = ieee754(a_src)
        if a_src < 0 :
            a_sqrt_src = 0
        else :
            a_sqrt_src = a_src**0.5
        a_sqrt = ieee754(a_sqrt_src)

        f.write(a.hex +"_"  + a_sqrt.hex + "\n")



##############END OF PROGRAM###########################################################



