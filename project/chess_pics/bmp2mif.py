import binascii
from PIL import Image


# open the bmp file
def img2str(filename):
    img = Image.open(filename)
    imgdata = [(r, g, b) for (r, g, b) in img.getdata()]
    new_data = []
    line_counter = 0
    for (r, g, b) in imgdata:
        r = 1 if (r >= 128) else 0
        g = 1 if (g >= 128) else 0
        b = 1 if (b >= 128) else 0
        color = r * 4 + g * 2 + b
        new_data.append(str(line_counter) + ": " + str(color) + ";")
        line_counter += 1
    print(len(new_data))
    return new_data


# default size is 48*48
def create_mif(filename, content, width=3):
    with open(filename[:-4] + ".mif", 'w+') as f:
        f.write("DEPTH=" + str(len(content)) + ";\n")
        f.write("WIDTH=" + str(width) + ";\n")
        f.write("ADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n")
        f.write("CONTENT\nBEGIN\n")
        for line in content:
            f.write(line + "\n")
        f.write("END;")


filename = "board-24.bmp"
create_mif(filename, img2str(filename))
