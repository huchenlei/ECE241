import binascii
from PIL import Image
from sys import argv, stderr


def imgToHexStr(img_filename, size=(16,16)):
    """Returns a hex string representing a resized image in 3:3:2 RGB."""
    img = Image.open(img_filename)
    img.thumbnail(size, Image.ANTIALIAS)

    # Hack. 3:3:2 RGB is nonstandard.
    imgdata = [(r,g,b) for (r,g,b) in img.getdata()]
    new_data = list()
    for (r, g, b) in imgdata:
        rp = r >> 5
        gp = g >> 5
        bp = b >> 6
        new_data += [(rp << 5) + (gp << 2) + bp]

    img = img.convert("P")
    img = Image.new(img.mode, img.size)
    img.putdata(new_data)
    img.save("converted_%s" % img_filename)

    return '\n'.join([binascii.hexlify(x) for x in img.tostring()])

def generateHex(mapfile, charSize, numChars):

    filler = '\n'.join(["00"] * (charSize[0] * charSize[1]))

    result = dict((addr, filler) for addr in range(0, numChars))

    with open(mapfile) as charcode_to_img:
        for line in charcode_to_img:
            tokens = line.split()
            code = int(tokens[0])
            imgfile = tokens[1]
            result[code] = imgToHexStr(imgfile, charSize)

    return '\n'.join([v for _, v in result.iteritems()])


def main(argv):
    if len(argv) != 4:
        stderr.write("Expected usage: %s [mapfile] [charSize] [numChars].\n" % argv[0])
        exit(1)

    filename = argv[1]
    charSize = (int(argv[2]), int(argv[2]))
    numChars = int(argv[3])

    print "Generating hex bitmap ROM..."
    with open('%s.hex' % filename, 'wb') as hex_outfile:
        hex_outfile.write(generateHex(filename, charSize, numChars))
    print "Done. Wrote '%s.hex'" % filename

if __name__ == "__main__":
    main(argv)
