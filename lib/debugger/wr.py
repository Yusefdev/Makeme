import subprocess
import re
import sys
import os
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QTextEdit, QVBoxLayout,
    QWidget, QPushButton, QHBoxLayout
)
from PyQt5.QtGui import QTextCursor, QTextCharFormat, QColor, QFont, QPalette
from PyQt5.QtCore import Qt

class SourceViewer(QMainWindow):
    def __init__(self, file_path, error_line, variable, error_msg):
        super().__init__()
        self.setWindowTitle("Source Code Viewer with Inline Error Highlight")
        self.resize(900, 600)

        self.file_path = file_path
        self.error_line = error_line
        self.variable = variable
        self.error_msg = error_msg

        # Buttons
        self.btn_open_vscode = QPushButton("Open in VS Code (goto)")
        self.btn_open_file = QPushButton("Open file (system default)")

        self.btn_open_vscode.setToolTip(f'Open "{file_path}" at line {error_line} in VS Code')
        self.btn_open_file.setToolTip(f'Open "{file_path}" using system default application')

        self.btn_open_vscode.clicked.connect(self.open_in_vscode_goto)
        self.btn_open_file.clicked.connect(self.open_file_system)

        # Style buttons: blue background, white text
        btn_style = """
            QPushButton {
                background-color: #0078d7;
                color: white;
                border-radius: 4px;
                padding: 6px 12px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #005a9e;
            }
            QPushButton:pressed {
                background-color: #003f6b;
            }
        """
        self.btn_open_vscode.setStyleSheet(btn_style)
        self.btn_open_file.setStyleSheet(btn_style)

        btn_layout = QHBoxLayout()
        btn_layout.addStretch()
        btn_layout.addWidget(self.btn_open_vscode)
        btn_layout.addWidget(self.btn_open_file)

        # Text editor
        self.text_edit = QTextEdit()
        self.text_edit.setReadOnly(True)
        font = QFont("Courier", 11)
        self.text_edit.setFont(font)

        # Main layout
        central_widget = QWidget()
        main_layout = QVBoxLayout()
        main_layout.addLayout(btn_layout)
        main_layout.addWidget(self.text_edit)
        central_widget.setLayout(main_layout)
        self.setCentralWidget(central_widget)

        self.apply_dark_theme()

        self.load_file(file_path)
        self.highlight_error(error_line, variable)
        self.insert_error_message(error_line, error_msg)

        # Scroll to error line nicely
        scrollbar = self.text_edit.verticalScrollBar()
        scrollbar.setValue(error_line - 5 if error_line > 5 else 0)

    def apply_dark_theme(self):
        palette = QPalette()
        palette.setColor(QPalette.Window, QColor("#121212"))
        palette.setColor(QPalette.WindowText, Qt.white)
        palette.setColor(QPalette.Base, QColor("#1e1e1e"))
        palette.setColor(QPalette.Text, QColor("#d4d4d4"))
        palette.setColor(QPalette.Button, QColor("#2d2d30"))
        palette.setColor(QPalette.ButtonText, Qt.white)
        palette.setColor(QPalette.Highlight, QColor("#264f78"))
        palette.setColor(QPalette.HighlightedText, Qt.white)
        self.setPalette(palette)
        self.text_edit.setPalette(palette)

    def load_file(self, path):
        with open(path, 'r') as f:
            self.source_lines = f.readlines()
        self.text_edit.setPlainText("".join(self.source_lines))

    def highlight_error(self, line_num, var_name=None):
        cursor = self.text_edit.textCursor()
        block = self.text_edit.document().findBlockByLineNumber(line_num - 1)
        cursor.setPosition(block.position())
        cursor.movePosition(QTextCursor.EndOfBlock, QTextCursor.KeepAnchor)

        fmt = QTextCharFormat()
        fmt.setBackground(QColor("#5a1a1a"))  # dark red background
        fmt.setForeground(QColor("#ff8080"))  # light red text
        cursor.setCharFormat(fmt)

        # Highlight variable with stronger red + bold
        if var_name:
            line_text = self.source_lines[line_num - 1]
            var_index = line_text.find(var_name)
            if var_index != -1:
                cursor.clearSelection()
                cursor.setPosition(block.position() + var_index)
                cursor.movePosition(QTextCursor.Right, QTextCursor.KeepAnchor, len(var_name))
                fmt_var = QTextCharFormat()
                fmt_var.setBackground(QColor("#b33a3a"))
                fmt_var.setFontWeight(QFont.Bold)
                fmt_var.setForeground(QColor("#fff0f0"))
                cursor.setCharFormat(fmt_var)

    def insert_error_message(self, line_num, msg):
        cursor = self.text_edit.textCursor()
        block = self.text_edit.document().findBlockByLineNumber(line_num - 1)
        pos = block.position() + block.length()
        cursor.setPosition(pos)
        cursor.insertText("\n")

        fmt_msg = QTextCharFormat()
        fmt_msg.setForeground(QColor("#ff6666"))  # red text
        fmt_msg.setFontItalic(True)
        cursor.setCharFormat(fmt_msg)
        cursor.insertText(f"⚠️  Error: {msg}")

        cursor.insertText("\n")

    def open_in_vscode_goto(self):
        # Correct format: file:line (no quotes)
        try:
            cmd = f'code -g {self.file_path}:{self.error_line}'
            subprocess.run(["cmd.exe", "/c", cmd])
            print(f"[*] Opened VS Code at {self.file_path}:{self.error_line}")
        except Exception as e:
            print(f"[!] Failed to open VS Code: {e}")

    def open_file_system(self):
        # Open file with default system application (Windows only)
        try:
            os.startfile(self.file_path)
            print(f"[*] Opened file with system default: {self.file_path}")
        except Exception as e:
            print(f"[!] Failed to open file: {e}")

# --- GDB parsing and running part ---

C_FILE = "buggy_mt.c"
EXECUTABLE = "buggy_mt.out"
GDB_LOG = "gdb_output.txt"

def compile_code():
    print("[*] Compiling with pthread support...")
    result = subprocess.run(
        ["gcc", "-g", "-O0", C_FILE, "-o", EXECUTABLE, "-pthread"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    if result.returncode != 0:
        print("[!] Compilation failed:")
        print(result.stderr)
        sys.exit(1)
    print("[+] Compilation succeeded.")

def run_gdb():
    print("[*] Running GDB with multi-thread commands...")
    gdb_cmds = [
        "run",
        "info threads",
        "thread apply all bt",
        "thread 0",
        "info locals",
        "list",
        "quit"
    ]
    with open("gdb_cmds.txt", "w") as f:
        f.write("\n".join(gdb_cmds))

    with open(GDB_LOG, "w") as out:
        subprocess.run(
            ["gdb", "--batch", "-x", "gdb_cmds.txt", f"./{EXECUTABLE}"],
            stdout=out,
            stderr=subprocess.STDOUT
        )

def parse_crash_info():
    print("[*] Analyzing GDB output...")
    with open(GDB_LOG, "r") as f:
        gdb_output = f.read()

    error_type = None
    err_match = re.search(r"Program received signal ([^,]+),", gdb_output)
    if err_match:
        error_type = err_match.group(1)
    else:
        error_type = "Unknown Error"

    loc_match = re.search(r'#0\s+.*\s+at\s+(\S+):(\d+)', gdb_output)
    if not loc_match:
        print("[!] Could not find crash line.")
        print(gdb_output)
        sys.exit(1)

    file_path = loc_match.group(1)
    line_number = int(loc_match.group(2))

    source_line = ""
    try:
        with open(file_path, "r") as f:
            lines = f.readlines()
            source_line = lines[line_number - 1].strip()
    except Exception as e:
        print(f"[!] Could not read source file: {e}")

    var_match = re.search(r'(\*?\w+)\s*=', source_line)
    variable = var_match.group(1) if var_match else None

    error_msg = f"{error_type}: suspected crash at line {line_number}"

    print(f"[+] Crash type: {error_type}")
    print(f"[+] Crash at {file_path}:{line_number}")
    print(f"[+] Source line: {source_line}")
    if variable:
        print(f"[🧠] Suspected variable: {variable}")

    return file_path, line_number, variable, error_msg

def main():
    compile_code()
    run_gdb()
    file_path, line_number, variable, error_msg = parse_crash_info()

    app = QApplication(sys.argv)
    viewer = SourceViewer(file_path, line_number, variable, error_msg)
    viewer.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()