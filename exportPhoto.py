import Image
import os
import getopt
import mimetypes
import datetime
import logging as log

from sys import exit, argv
from shutil import copy2
from filecmp import cmp


class Item(object):
    def __init__(self, basesrc, filename, basedst, prefix=""):
        self.source = os.path.join(basesrc, filename)
        self.destination = os.path.join(basedst, prefix + filename)

    def Processing(self, itemlist):
        if os.path.isfile(self.destination) and\
           cmp(self.source, self.destination):
            log.debug("no need to process %s" % self.source)
        else:
            log.info("processing %s => %s" % (self.source, self.destination))
            itemlist.append(self)


class exifImage(Item):
    def __init__(self, basesrc, filename, basedst):
        super(exifImage, self).__init__(basesrc, filename, basedst)
        self.destination = self.parseExifForDst()

    def parseExifForDst(self):
        try:
            log.debug("image : %s" % self.source)
            image = Image.open(self.source)
            cdate, ctime = image._getexif()[36867].split(' ')
        except KeyError, err:
            log.info("KeyError : %s on %s" % (err, self.source))
            cdate, ctime = ("0000:00:00", "00:00:00")
        except IOError, err:
            log.info("IOError : %s on %s" % (err, self.source))
            exit(3)
        except AttributeError, err:
            log.info("AttributeError : %s on %s" % (err, self.source))
            cdate, ctime = ("0000:00:00", "00:00:00")
        log.debug("cdate : %s | ctime : %s" % (cdate, ctime))
        year, month, day = cdate.split(':')
        try:
            rdate = datetime.date(int(year), int(month), int(day))
        except ValueError, err:
            log.debug("ValueError : %s" % err)
            rdate = datetime.date(1970, 01, 01)
        return os.path.join(os.path.dirname(self.destination), '%s/%s-%s' % (
                            rdate.strftime("%Y/%m_%B/%d_%A"),
                            ctime.replace(':', ''),
                            os.path.basename(self.source)))


def process(filelist):
    for item in filelist:
        if not os.path.exists(os.path.dirname(item.destination)):
            log.info("creating directory %s" %
                     os.path.dirname(item.destination))
            os.makedirs(os.path.dirname(item.destination))
        log.info("copying %s => %s" % (item.source, item.destination))
        copy2(item.source, item.destination)


def main():
    # Ajout des types de fichier que je sui sur de rencontrer
    mimetypes.add_type('video', '.mkv')

    try:
        opts, args = getopt.getopt(argv[1:], 's:d:vDp')
    except getopt.GetoptError, err:
        print str(err)
        exit(2)

    for o, a in opts:
        if o == '-s':
            imgsrc = a
        elif o == '-d':
            imgdst = a
        elif o == '-v':
            log.basicConfig(level=log.INFO)
            log.info("OK")
        elif o == '-D':
            log.basicConfig(level=log.DEBUG)
            log.debug("OK")
        elif o == '-p':
            shownotprocess = 1
        else:
            log.error("unknown option %s" % o)

    if 'imgsrc' not in locals() or 'imgdst' not in locals():
        log.warn('imgdirs not defined : use -s source -d dest')
        exit(2)

    imglist = []
    videolist = []
    xmplist = []
    otherlist = []

    for dirname, dirnames, filenames in os.walk(imgsrc):
        # print path to all filenames.
        for filename in filenames:
            ext = filename.split('.')[-1].lower()
            try:
                mtype = mimetypes.types_map['.%s' % ext].split('/')[0]
            except KeyError, err:
                log.debug("KeyError : %s on %s" % (err, filename))
                mtype = 'other'
            except TypeError, err:
                log.debug("TypeError : %s on %s" % (err, filename))
                mtype = 'other'
            if mtype == 'image':
                try:
                    item = exifImage(dirname, filename, imgdst)
                except TypeError, err:
                    log.debug("TypeError : %s on %s" % (err, filename))
                    if filename.startswith("."):
                        log.debug("hidden file, nevermind...")
                        continue
                    else:
                        log.warn("file not handle %s" % filename)
                        otherlist.append(item)
                        continue
                item.Processing(imglist)
                # add xmp if exists
                if os.path.isfile('%s.xmp' % item.source):
                    prefix = os.path.basename(item.destination).split("-")[0]
                    xmp = Item(os.path.dirname(item.source),
                               '%s.xmp' % filename,
                               os.path.dirname(item.destination),
                               prefix + "-")
                    xmp.Processing(xmplist)
            elif mtype == 'video':
                item = Item(dirname, filename, os.path.join(imgdst, "video"))
                item.Processing(videolist)
            else:
                item = Item(dirname, filename, imgdst)
                otherlist.append(item)

    process(imglist)
    process(videolist)
    process(xmplist)

    if "shownotprocess" in locals():
        print "file not processed"
        for item in otherlist:
            print item.source

if __name__ == '__main__':
    main()
