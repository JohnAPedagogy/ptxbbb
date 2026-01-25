obj-m += ldd.o
all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules KBUILD_MODPOST_WARN=1

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
