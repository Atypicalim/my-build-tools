
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
    unsigned char *image_data = stbi_load(argv[1], &width, &height, &channels, 0);
    if (!image_data) {
        printf("read [%s] failed!\n", argv[1]);
        return 1;
    }
    //
    printf("read [%s] finished!\n", argv[1]);
    printf("Width: %d\n", width);
    printf("Height: %d\n", height);
    printf("Channels: %d\n", channels);
    //
    stbi_write_png(argv[2], width, height, channels, image_data, width * channels);
    stbi_image_free(image_data);
    //
    printf("write [%s] with png format finished!\n", argv[2]);
    system("pause"); 
    return 0;
}
