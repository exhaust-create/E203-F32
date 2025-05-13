import bitstring, random

span = 800000
iteration = 100000

def ieee754(flt):
    b = bitstring.BitArray(float=flt, length=32)
    return b

def int32(input):
    b = bitstring.BitArray(int=input, length=32)
    return b

with open("TestVectorFp2Int", "w") as f:

    for i in range(iteration):
        a_src = random.uniform(-span, span)
        a = ieee754(a_src)
        a_int = int(a_src)
        a_fp2int = int32(a_int)

        f.write(a.hex +"_"  + a_fp2int.hex + "\n")



##############END OF PROGRAM###########################################################



