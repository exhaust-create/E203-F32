onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib reset_sys_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {reset_sys.udo}

run 1000ns

quit -force
