import bitstring, random

span = 800000
iteration = 100000

def ieee754(flt):
    b = bitstring.BitArray(float=flt, length=32)
    return b

def int32(input):
    b = bitstring.BitArray(int=input, length=32)
    return b

with open("TestVectorInt2Fp", "w") as f:

    for i in range(iteration):
        a_src = random.randint(-span, span)
        a = int32(a_src)
        a_fp_src = float(a_src)
        a_fp = ieee754(a_fp_src)

        f.write(a.hex +"_"  + a_fp.hex + "\n")



##############END OF PROGRAM###########################################################



