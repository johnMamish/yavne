#!/usr/bin/env python


def main():
    qf = open("sd.mif", 'w+')
    for i in range( 2**16):
        for j in range(512):
            if i < 2**15:
                qf.write(chr(4))
            else:
                qf.write(chr(16))
    qf.close()
    print("done!")

if __name__ == "__main__":
    main()

