#include <stdio.h>
#include "ipc_comm_win.h"

void on_message(const char *msg, size_t len) {
    printf("Received from client: %.*s\n", (int)len, msg);
}

int main() {
    ipc_connection_t conn;
    ipc_set_callback(&conn, on_message);

    if (ipc_server_start(&conn, "TestPipe") == 0) {
        printf("Named pipe server started. Waiting for client...\n");
        getchar(); // Wait for user input to terminate
    } else {
        fprintf(stderr, "Failed to start server\n");
    }

    ipc_close(&conn);
    return 0;
}