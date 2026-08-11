#include <unistd.h>
int main(void){

    int nread; char buffer[120];
    nread = read(0, buffer, 120);
    if (nread == -1) write(2, "An error has occurred\n", 21);
    else write(1, buffer, nread);

return 0;
}