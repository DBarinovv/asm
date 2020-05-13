#include <stdio.h>

//=============================================================================

const char C_address = 0x11f6;

const char C_xor = 0x31;

//=============================================================================

int main ()
{
    FILE *fin = fopen ("to_crack", "r+b");

    fseek (fin, C_address, SEEK_SET);
    fputc (C_xor, fin);

    fclose (fin);

    return 0;
}
