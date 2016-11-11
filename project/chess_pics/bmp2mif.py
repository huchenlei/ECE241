from PIL import Image


def img2str(filename, color_type=1):
    img = Image.open(filename)
    imgdata = [(r, g, b) for (r, g, b) in img.getdata()]
    new_data_3bit = []
    new_data_2bit = []
    new_data_mono = []
    line_counter = 0
    for (r, g, b) in imgdata:
        # 3bit color
        r3 = 1 if (r >= 128) else 0
        g3 = 1 if (g >= 128) else 0
        b3 = 1 if (b >= 128) else 0
        color = r3 * 4 + g3 * 2 + b3
        new_data_3bit.append(str(line_counter) + ": " + str(color) + ";")
        # 2 bit color(red as alpha)
        a2 = 1 if (r > g or r > b) else 0
        w = 1 if ((g == b == r) and (g > 128)) else 0
        color = a2 * 2 + w
        new_data_2bit.append(str(line_counter) + ": " + str(color) + ";")
        # 1 bit color
        w = 1 if ((g == b == r) and (g > 128)) else 0
        new_data_mono.append(str(line_counter) + ": " + str(w) + ";")
        line_counter += 1
    print("The depth of picture is ", len(new_data_3bit))
    if color_type == 3:
        return new_data_3bit
    elif color_type == 2:
        return new_data_2bit
    elif color_type == 1:
        return new_data_mono


# default color is 3 bit
def create_mif(filename, content, width=3):
    with open(filename[:-4] + ".mif", 'w+') as f:
        f.write("DEPTH=" + str(len(content)) + ";\n")
        f.write("WIDTH=" + str(width) + ";\n")
        f.write("ADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n")
        f.write("CONTENT\nBEGIN\n")
        for line in content:
            f.write(line + "\n")
        f.write("END;")


filename = input("Please input file name(.bmp):")
color_type = int(input("Please input convert type(3, 2, 1):"))
create_mif(filename, img2str(filename, color_type), color_type)
