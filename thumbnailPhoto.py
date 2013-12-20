import os
import getopt
import logging as log

from sys import exit, argv
from PIL import Image


def main():

    try:
        opts, args = getopt.getopt(argv[1:], 's:d:w:h:vD')
    except getopt.GetoptError, err:
        print str(err)
        exit(2)

    width = 1920
    height = 1080
    for o, a in opts:
        if o == '-s':
            imgsrc = a
        elif o == '-d':
            imgdst = a
        elif o == '-w':
            width = a
        elif o == '-h':
            height = a
        elif o == '-v':
            log.basicConfig(level=log.INFO)
            log.info("OK")
        elif o == '-D':
            log.basicConfig(level=log.DEBUG)
            log.debug("OK")
        else:
            log.error("unknown option %s" % o)

    if 'imgsrc' not in locals() or 'imgdst' not in locals():
        log.warn('imgdirs not defined : use -s source -d dest')
        exit(2)

    size = width, height
    for filename in os.listdir(imgsrc):
        if os.path.isfile(os.path.join(imgsrc, filename)):
            img = Image.open(os.path.join(imgsrc, filename))
            img.thumbnail(size)
            img.save(os.path.join(imgdst, "t_%s" % filename))

if __name__ == '__main__':
    main()
