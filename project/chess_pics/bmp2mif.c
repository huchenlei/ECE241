// karimov 2005

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  FILE *f, *fm;
  unsigned int y, x;
  long width, height;
  short depth;
  unsigned short red, green, blue, sum;

  printf("This program converts 412x480  24-bit .BMP image to MIF file\n");
  printf("Make sure BMP file is vertically flipped (upside down)\n");

  f = fopen("rook_r.bmp", "rb");
  fm = fopen("rook_r.mif", "wb");

  if (f) {
    fseek(f, 15, SEEK_SET);
    fread(&width, sizeof(width), 1, f);
    fseek(f, 19, SEEK_SET);
    fread(&height, sizeof(height), 1, f);
    fseek(f, 27, SEEK_SET);
    fread(&depth, sizeof(depth), 1, f);

    printf("Input file is %lix%li %i-bit depth\n", width, height, depth);

    if (depth == 24) {
      printf("Converting...\n");

      fseek(f, 54, SEEK_SET);
      for (y = 0; y < 480; y++) {
        x = 0;
        for (x = 0; x < 412; x++) {

          fread(&blue, 1, 1, f);
          fread(&green, 1, 1, f);
          fread(&red, 1, 1, f);

          red = (red & 0xf800);
          green = (green & 0xfC00) >> 5;
          blue = (blue & 0xf800) >> 11;

          sum = red + green + blue;

          fwrite(&sum, 2, 1, fm);
        }
      }

    } else
      printf("Input file image.bmp is not 412x480 24-bit!\n");
    fclose(fm);
    fclose(f);
    printf("All done.\n");
  } else
    printf("Cannot open input file. Check for input.bmp\n");
}
