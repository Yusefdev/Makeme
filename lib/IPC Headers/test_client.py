import win32api as win32pipe
import win32file as win32file
import time

pipe_name = r'\\.\pipe\TestPipe'

def main():
    try:
        handle = win32file.CreateFile(
            pipe_name,
            win32file.GENERIC_WRITE | win32file.GENERIC_READ,
            0,
            None,
            win32file.OPEN_EXISTING,
            0,
            None
        )

        for i in range(3):
            msg = f"Hello from Python {i}"
            win32file.WriteFile(handle, msg.encode())
            print(f"Sent: {msg}")
            time.sleep(1)

        win32file.CloseHandle(handle)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()