import argparse
import os
import pexif
from PIL import Image

parser = argparse.ArgumentParser(description=("Copy and resize images with" +
                                              "conservation of directory structure"))
parser.add_argument('srcdir', help='source directory', type=str)
parser.add_argument('dstdir', help='destination dir', type=str)
parser.add_argument('-f', '--force', help='force copy (is dstdir not empty)',
                    action='store_const', const=True, dest="force")
parser.add_argument('-s', '--size', help='size (default=1920x1080)', default="1920x1080", type=str)

args = parser.parse_args()

width, height = args.size.split('x')
size = (int(width), int(height))
imgtype = ["jpg", "JPG", "jpeg", "JPEG", "PNG", "png"]

"""values extracted from PIL.ExifTags.TAGS"""
DateTime = 306
DateTime_fallback = 36867
Make = 271
Model = 272
FNumber = 33437
FocalLength = 37386
ExposureTime = 33434

def resizeImage(src, dst, size):
    try:
        img = Image.open(srcimg)
        img.thumbnail(size, Image.ANTIALIAS)
        img.save(dstimg)
    except IOError, e:
        print "IOError: %s" % e
        print "on : %s" % srcimg
        return False
    return True

def copyExifData(src, dst):
    try:
        exifdst = pexif.JpegFile.fromFile(dst)
    except:
        print "Invalid Dest: %s" % dst
        exit()
    try:
        exifsrc = pexif.JpegFile.fromFile(src).exif.primary
        exifdst.exif.primary.entries = exifsrc.entries
    except:
        print "InvalidFile: %s" % src
        exif =  Image.open(src)._getexif()
        if exif.has_key(DateTime):
            exifdst.exif.primary.DateTime = exif[DateTime]
        elif exif.has_key(DateTime_fallback):
            exifdst.exif.primary.DateTime = exif[DateTime_fallback]
        if exif.has_key(Make):
            exifdst.exif.primary.Make = exif[Make]
        if exif.has_key(Model):
            exifdst.exif.primary.Model = exif[Model]
        if exif.has_key(FNumber):
            exifdst.exif.primary.FocalLength = exif[FocalLength]
        if exif.has_key(ExposureTime):
            exifdst.exif.primary.ExposureTime = exif[ExposureTime]
        
    exifdst.writeFile(dst)

if os.path.isdir(args.dstdir) and len(os.listdir(args.dstdir)) != 0 and not args.force:
    print "%s is not empty, use --force or change dstdir" % args.dstdir
    exit()

for root, dirs, files in os.walk(args.srcdir):
    for rep in dirs:
        leaf = os.path.join(root, rep).lstrip(args.srcdir)
        fulldst = os.path.join(args.dstdir, leaf)
        if not os.path.isdir(fulldst):
            os.mkdir(fulldst)

    for image in files:
        ext = image.split(".")[-1]
        if ext in imgtype:
            srcimg = os.path.join(root, image)
            leaf = srcimg.lstrip(args.srcdir)
            dstimg = os.path.join(args.dstdir, leaf)
            if not os.path.isfile(dstimg):
                if resizeImage(srcimg, dstimg, size):
                    copyExifData(srcimg, dstimg)
