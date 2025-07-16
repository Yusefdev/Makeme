#ifndef IPC_COMM_WIN_H
#define IPC_COMM_WIN_H

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>

#define IPC_BUFFER_SIZE 1024

typedef void (*ipc_callback_t)(const char *msg, size_t len);

typedef struct {
    HANDLE handle;
    HANDLE thread;
    ipc_callback_t callback;
    int is_server;
    int running;
    char pipe_name[256];
} ipc_connection_t;

DWORD WINAPI ipc_receive_loop(LPVOID param) {
    ipc_connection_t *conn = (ipc_connection_t *)param;
    char buffer[IPC_BUFFER_SIZE];
    DWORD bytesRead;

    while (conn->running) {
        BOOL success = ReadFile(
            conn->handle,
            buffer,
            IPC_BUFFER_SIZE - 1,
            &bytesRead,
            NULL
        );

        if (success && bytesRead > 0 && conn->callback) {
            buffer[bytesRead] = '\0';
            conn->callback(buffer, bytesRead);
        } else {
            if (conn->is_server) {
                DisconnectNamedPipe(conn->handle);
                ConnectNamedPipe(conn->handle, NULL);
            } else {
                break;
            }
        }
    }

    return 0;
}

int ipc_server_start(ipc_connection_t *conn, const char *pipe_name) {
    snprintf(conn->pipe_name, sizeof(conn->pipe_name), "\\\\.\\pipe\\%s", pipe_name);

    conn->handle = CreateNamedPipeA(
        conn->pipe_name,
        PIPE_ACCESS_DUPLEX,
        PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
        PIPE_UNLIMITED_INSTANCES,
        IPC_BUFFER_SIZE,
        IPC_BUFFER_SIZE,
        0,
        NULL
    );

    if (conn->handle == INVALID_HANDLE_VALUE) return -1;

    BOOL connected = ConnectNamedPipe(conn->handle, NULL) ?
                     TRUE : (GetLastError() == ERROR_PIPE_CONNECTED);

    if (!connected) return -2;

    conn->is_server = 1;
    conn->running = 1;

    if (conn->callback) {
        conn->thread = CreateThread(NULL, 0, ipc_receive_loop, conn, 0, NULL);
    }

    return 0;
}

int ipc_client_connect(ipc_connection_t *conn, const char *pipe_name) {
    snprintf(conn->pipe_name, sizeof(conn->pipe_name), "\\\\.\\pipe\\%s", pipe_name);

    while (1) {
        conn->handle = CreateFileA(
            conn->pipe_name,
            GENERIC_READ | GENERIC_WRITE,
            0,
            NULL,
            OPEN_EXISTING,
            0,
            NULL
        );

        if (conn->handle != INVALID_HANDLE_VALUE)
            break;

        if (GetLastError() != ERROR_PIPE_BUSY) return -1;
        if (!WaitNamedPipeA(conn->pipe_name, 5000)) return -2;
    }

    conn->is_server = 0;
    conn->running = 1;

    if (conn->callback) {
        conn->thread = CreateThread(NULL, 0, ipc_receive_loop, conn, 0, NULL);
    }

    return 0;
}

void ipc_set_callback(ipc_connection_t *conn, ipc_callback_t cb) {
    conn->callback = cb;
}

int ipc_send(ipc_connection_t *conn, const char *msg, size_t len) {
    DWORD bytesWritten;
    BOOL success = WriteFile(
        conn->handle,
        msg,
        (DWORD)len,
        &bytesWritten,
        NULL
    );

    return success ? (int)bytesWritten : -1;
}

void ipc_close(ipc_connection_t *conn) {
    conn->running = 0;
    if (conn->callback && conn->thread)
        WaitForSingleObject(conn->thread, INFINITE);

    CloseHandle(conn->handle);
    if (conn->thread) CloseHandle(conn->thread);
}

#endif // IPC_COMM_WIN_H