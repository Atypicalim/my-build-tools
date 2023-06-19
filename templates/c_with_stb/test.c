
#include <stdio.h>
#include <stdlib.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

int main(int argc, char *argv[])
{
    //
    int width, height, channels;
    unsigned char *data = stbi_load(argv[1], &width, &height, &channels, 0);
    if (!data) {
        printf("read [%s] failed!\n", argv[1]);
        return 1;
    }
    //
    printf("read [%s] finished!\n", argv[1]);
    printf("Width: %d\n", width);
    printf("Height: %d\n", height);
    printf("Channels: %d\n", channels);
    //
    unsigned bytePerPixel = channels;
    for (int x = 0; x < 100; x++) {
        for (int y = 0; y < 100; y++) {
            int offset = channels * (y * width + x);
            data[offset + 0] = 0;
            data[offset + 1] = data[offset + 1] / 1;
            data[offset + 2] = data[offset + 2] / 2;
        }
    }
    //
    stbi_write_png(argv[2], width, height, channels, data, width * channels);
    stbi_image_free(data);
    //
    printf("write [%s] with png format finished!\n", argv[2]);
    system("pause"); 
    return 0;
}
