import os
import sys
import json
import subprocess
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QListWidget, QTextEdit, QVBoxLayout, QWidget,
    QLabel, QPushButton, QFormLayout, QLineEdit, QHBoxLayout, QComboBox, QCheckBox,
    QSpinBox, QScrollArea, QMessageBox, QToolBar, QAction, QListView, QAbstractItemView,
    QSplitter, QFrame, QPlainTextEdit, QSizePolicy
)
from PyQt5.QtCore import Qt, QStringListModel, QSettings
from PyQt5.QtGui import QIcon, QFont

class ConfigEditor(QMainWindow):
    def __init__(self, working_dir, msys2_path=None):
        super().__init__()
        self.working_dir = working_dir
        self.msys2_path = msys2_path
        self.config_file = os.path.join(working_dir, 'makeme_config.json')
        # Load theme setting from Windows registry
        self.settings = QSettings('ConfigEditor', 'Settings')
        self.dark_theme = self.settings.value('darkTheme', False, type=bool)
        
        self.setWindowTitle('Config Editor')
        self.setGeometry(100, 100, 1200, 800)
        
        self.create_toolbar()
        self.create_ui()
        self.load_config()
        self.apply_theme()
        
    def create_toolbar(self):
        toolbar = QToolBar()
        self.addToolBar(toolbar)
        
        # Theme toggle button
        theme_action = QAction('🌙 Toggle Theme', self)
        theme_action.triggered.connect(self.toggle_theme)
        toolbar.addAction(theme_action)
        
        # Add spacer to push theme button to the right
        spacer = QWidget()
        spacer.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Preferred)
        toolbar.addWidget(spacer)
        
    def create_ui(self):
        # Main splitter
        main_splitter = QSplitter(Qt.Horizontal)
        
        # Left panel - File list
        left_panel = QWidget()
        left_layout = QVBoxLayout()
        left_panel.setLayout(left_layout)
        
        left_layout.addWidget(QLabel('Files:'))
        self.file_list = QListWidget()
        self.file_list.currentItemChanged.connect(self.show_file_settings)
        left_layout.addWidget(self.file_list)
        
        # Right panel - Settings
        self.right_panel = QWidget()
        right_layout = QVBoxLayout()
        self.right_panel.setLayout(right_layout)
        
        # Selected file name label
        self.selected_file_label = QLabel('No file selected')
        self.selected_file_label.setStyleSheet('font-weight: bold; font-size: 14px; padding: 10px;')
        right_layout.addWidget(self.selected_file_label)
        
        # Settings form
        settings_scroll = QScrollArea()
        settings_widget = QWidget()
        self.settings_layout = QFormLayout()
        settings_widget.setLayout(self.settings_layout)
        settings_scroll.setWidget(settings_widget)
        settings_scroll.setWidgetResizable(True)
        
        # Create form fields
        self.create_form_fields()
        
        # Command display
        right_layout.addWidget(QLabel('Generated Command:'))
        self.command_display = QPlainTextEdit()
        self.command_display.setMaximumHeight(100)
        self.command_display.setReadOnly(True)
        right_layout.addWidget(self.command_display)
        
        # Copy button
        self.copy_button = QPushButton('Copy Command')
        self.copy_button.clicked.connect(self.copy_command)
        right_layout.addWidget(self.copy_button)
        
        right_layout.addWidget(settings_scroll)
        
        # Add panels to splitter
        main_splitter.addWidget(left_panel)
        main_splitter.addWidget(self.right_panel)
        main_splitter.setSizes([300, 900])
        
        # Initially hide the right panel
        self.right_panel.setVisible(False)
        
        self.setCentralWidget(main_splitter)
        
    def create_form_fields(self):
        # Compile Order
        self.compile_order = QSpinBox()
        self.compile_order.setMinimum(1)
        self.compile_order.setMaximum(999)
        self.compile_order.valueChanged.connect(self.update_command)
        self.settings_layout.addRow(QLabel('Compile Order:'), self.compile_order)
        
        # Compiler dropdown
        self.compiler_combo = QComboBox()
        self.compiler_combo.addItems(['gcc', 'clang', 'g++', 'clang++'])
        self.compiler_combo.setEditable(False)
        self.compiler_combo.currentTextChanged.connect(self.update_language_standards)
        self.compiler_combo.currentTextChanged.connect(self.update_command)
        self.settings_layout.addRow(QLabel('Compiler:'), self.compiler_combo)
        
        # Architecture dropdown
        self.architecture_combo = QComboBox()
        self.architecture_combo.addItems(['x86', 'x64'])
        self.architecture_combo.setEditable(True)
        self.architecture_combo.currentTextChanged.connect(self.on_architecture_changed)
        self.settings_layout.addRow(QLabel('Architecture:'), self.architecture_combo)
        
        # Compile type dropdown
        self.compile_type_combo = QComboBox()
        self.compile_type_combo.addItems(['.exe (debug)', '.exe (release)', '.dll', '.lib', '.obj', '.so'])
        self.compile_type_combo.setEditable(True)
        self.compile_type_combo.currentTextChanged.connect(self.update_command)
        self.settings_layout.addRow(QLabel('Compile Type:'), self.compile_type_combo)
        
        # Output path
        self.output_path_input = QLineEdit()
        self.output_path_input.textChanged.connect(self.update_command)
        self.settings_layout.addRow(QLabel('Output Path:'), self.output_path_input)
        
        # Custom output name
        self.custom_output_name_input = QLineEdit()
        self.custom_output_name_input.textChanged.connect(self.update_command)
        self.settings_layout.addRow(QLabel('Custom Output Name:'), self.custom_output_name_input)
        
        # Language standard dropdown
        self.language_standard_combo = QComboBox()
        self.update_language_standards()
        self.language_standard_combo.setEditable(True)
        self.language_standard_combo.currentTextChanged.connect(self.update_command)
        self.settings_layout.addRow(QLabel('Language Standard:'), self.language_standard_combo)
        
        # Package selection (if MSYS2 is available)
        if self.msys2_path:
            self.package_list_view = QListView()
            self.package_list_view.setSelectionMode(QAbstractItemView.MultiSelection)

            self.package_search = QLineEdit()
            self.package_search.setPlaceholderText('Search packages...')
            self.package_search.textChanged.connect(self.filter_packages)

            self.package_list_view.setMaximumHeight(150)

            self.settings_layout.addRow(QLabel('Packages:'), self.package_search)
            self.settings_layout.addRow(self.package_list_view)
            self.load_packages()
        
        # Save button
        self.save_button = QPushButton('Save Changes')
        self.save_button.clicked.connect(self.save_changes)
        self.settings_layout.addRow(self.save_button)
        
    def load_packages(self):
        """Load available packages from MSYS2"""
        if not self.msys2_path:
            return

        architecture = 'mingw64' if self.architecture_combo.currentText() == 'x64' else 'mingw32'
        pkg_config_dir = os.path.join(self.msys2_path, architecture, 'lib', 'pkgconfig')

        if not os.path.isdir(pkg_config_dir):
            return

        try:
            packages = []
            for file in os.listdir(pkg_config_dir):
                if file.endswith('.pc'):
                    pkg_name = file[:-3].lower()  # Remove .pc extension and lowercase
                    packages.append(pkg_name)

            self.package_list_model = QStringListModel()
            self.package_list_model.setStringList(sorted(packages))
            self.package_list_view.setModel(self.package_list_model)
            
            # Connect selection changed signal after model is set
            if self.package_list_view.selectionModel():
                self.package_list_view.selectionModel().selectionChanged.connect(self.update_command)
        except Exception as e:
            print(f"Error loading packages: {e}")
            
    def toggle_theme(self):
        self.dark_theme = not self.dark_theme
        # Save theme setting to Windows registry
        self.settings.setValue('darkTheme', self.dark_theme)
        self.apply_theme()
        
    def filter_packages(self, text):
        if hasattr(self, 'package_list_model'):
            all_packages = getattr(self, 'all_packages', [])
            if not all_packages:
                all_packages = self.package_list_model.stringList()
                self.all_packages = all_packages
            
            filtered_list = [pkg for pkg in all_packages if text.lower() in pkg.lower()]
            self.package_list_model.setStringList(filtered_list)

    def on_architecture_changed(self):
        """Handle architecture change - reload packages and update command"""
        if hasattr(self, 'package_list_view') and self.msys2_path:
            # Clear search field to reload all packages
            if hasattr(self, 'package_search'):
                self.package_search.clear()
            # Reload packages for the new architecture
            self.load_packages()
        self.update_command()
    
    def update_language_standards(self):
        compiler = self.compiler_combo.currentText()
        language_standards = {
            'gcc': ['c89', 'c99', 'c11', 'gnu99', 'c++03', 'c++11', 'c++14', 'c++17', 'c++20'],
            'clang': ['c89', 'c99', 'c11', 'gnu99', 'c++03', 'c++11', 'c++14', 'c++17', 'c++20'],
            'g++': ['c++03', 'c++11', 'c++14', 'c++17', 'c++20'],
            'clang++': ['c++03', 'c++11', 'c++14', 'c++17', 'c++20']
        }
        standards = language_standards.get(compiler, [])
        self.language_standard_combo.clear()
        self.language_standard_combo.addItems(standards)

    def apply_theme(self):
        if self.dark_theme:
            self.setStyleSheet("""
                QMainWindow, QWidget {
                    background-color: #2b2b2b;
                    color: #ffffff;
                }
                QListView, QListWidget, QLineEdit, QComboBox, QSpinBox, QPlainTextEdit {
                    background-color: #3c3c3c;
                    border: 1px solid #555555;
                    color: #ffffff;
                    padding: 5px;
                }
                QListView::item:selected {
                    background-color: #4a4a4a;
                }
                QPushButton {
                    background-color: #0078d4;
                    color: white;
                    border: none;
                    padding: 8px 16px;
                    border-radius: 4px;
                }
                QPushButton:hover {
                    background-color: #106ebe;
                }
                QToolBar {
                    background-color: #404040;
                    border: none;
                }
                QLabel {
                    color: #ffffff;
                }
            """)
        else:
            self.setStyleSheet("""
                QMainWindow, QWidget {
                    background-color: #ffffff;
                    color: #000000;
                }
                QListView, QListWidget, QLineEdit, QComboBox, QSpinBox, QPlainTextEdit {
                    background-color: #ffffff;
                    border: 1px solid #cccccc;
                    color: #000000;
                    padding: 5px;
                }
                QListView::item:selected {
                    background-color: #e3f2fd;
                }
                QPushButton {
                    background-color: #0078d4;
                    color: white;
                    border: none;
                    padding: 8px 16px;
                    border-radius: 4px;
                }
                QPushButton:hover {
                    background-color: #106ebe;
                }
                QToolBar {
                    background-color: #f0f0f0;
                    border: none;
                }
                QLabel {
                    color: #000000;
                }
            """)
            
    def load_config(self):
        # Load files
        files = self.get_c_cpp_files()
        self.file_list.addItems(files)
        
        # Load config if exists
        if os.path.isfile(self.config_file):
            with open(self.config_file, 'r') as fp:
                self.config = json.load(fp)
        else:
            self.config = {'fileSettings': {}}
            
    def get_c_cpp_files(self):
        c_cpp_files = []
        for root, dirs, files in os.walk(self.working_dir):
            for file in files:
                if file.endswith(('.c', '.cpp', '.cxx', '.cc', '.h')):
                    c_cpp_files.append(os.path.relpath(os.path.join(root, file), self.working_dir))
        return c_cpp_files
        
    def show_file_settings(self, current, previous):
        if not current:
            self.right_panel.setVisible(False)
            self.selected_file_label.setText('No file selected')
            return
            
        # Show the right panel when a file is selected
        self.right_panel.setVisible(True)
        
        file_name = current.text()
        self.selected_file_label.setText(f'Selected File: {file_name}')
        settings = self.config['fileSettings'].get(file_name, {})
        self.display_file_settings(settings)
        
    def display_file_settings(self, settings):
        self.compile_order.setValue(settings.get('compileOrder', 1))
        
        compiler = settings.get('compiler', 'gcc')
        index = self.compiler_combo.findText(compiler)
        if index >= 0:
            self.compiler_combo.setCurrentIndex(index)
        
        architecture = settings.get('architecture', 'x64')
        index = self.architecture_combo.findText(architecture)
        if index >= 0:
            self.architecture_combo.setCurrentIndex(index)
        else:
            self.architecture_combo.setCurrentText(architecture)
            
        compile_type = settings.get('compileType', 'debug')
        index = self.compile_type_combo.findText(compile_type)
        if index >= 0:
            self.compile_type_combo.setCurrentIndex(index)
        else:
            self.compile_type_combo.setCurrentText(compile_type)
            
        self.output_path_input.setText(settings.get('outputPath', ''))
        self.custom_output_name_input.setText(settings.get('customOutputName', ''))
        
        language_standard = settings.get('languageStandard', 'c11')
        index = self.language_standard_combo.findText(language_standard)
        if index >= 0:
            self.language_standard_combo.setCurrentIndex(index)
        else:
            self.language_standard_combo.setCurrentText(language_standard)
            
        # Set selected packages
        if hasattr(self, 'package_list_view'):
            selected_packages = settings.get('packages', [])
            model = self.package_list_view.model()
            if model:
                selection_model = self.package_list_view.selectionModel()
                selection_model.clearSelection()
                for i in range(model.rowCount()):
                    package_name = model.data(model.index(i, 0), Qt.DisplayRole)
                    if package_name in selected_packages:
                        selection_model.select(model.index(i, 0), selection_model.Select)
                    
        self.update_command()
        
    def update_command(self):
        current_item = self.file_list.currentItem()
        if not current_item:
            self.command_display.setPlainText('')
            return
            
        file_name = current_item.text()
        command = self.generate_compile_command(file_name)
        self.command_display.setPlainText(command)
        
    def generate_compile_command(self, file_name):
        compiler = self.compiler_combo.currentText()
        architecture = self.architecture_combo.currentText()
        compile_type = self.compile_type_combo.currentText()
        output_path = self.output_path_input.text() or 'build/'
        custom_output_name = self.custom_output_name_input.text()
        language_standard = self.language_standard_combo.currentText()
        
        # Determine target architecture string like in main.dart
        target_arch = 'x86_64-w64-mingw32' if architecture == 'x64' else 'i686-w64-mingw32'
        
        # Build command parts
        command_parts = [compiler]
        
        # Add target architecture
        command_parts.extend(['-target', target_arch])
        
        # Add language standard
        if language_standard:
            command_parts.append(f'-std={language_standard}')
            
        # Add compile type specific flags
        if compile_type == '.exe (debug)':
            command_parts.extend(['-g', '-O0'])
        elif compile_type == '.exe (release)':
            command_parts.extend(['-O2', '-DNDEBUG'])
        elif compile_type == '.dll':
            command_parts.extend(['-shared'])
        elif compile_type == '.lib':
            command_parts.extend(['-static'])
        elif compile_type == '.obj':
            command_parts.append('-c')
        elif compile_type == '.so':
            command_parts.extend(['-shared', '-fPIC'])
        
        # Add package flags (pkg-config style like in main.dart)
        if hasattr(self, 'package_list_view'):
            selected_indexes = self.package_list_view.selectionModel().selectedIndexes()
            selected_packages = [self.package_list_view.model().data(i, Qt.DisplayRole) for i in selected_indexes]

            if selected_packages:
                pkg_config_flags = f'`pkg-config --cflags --libs {" ".join(selected_packages)}`'
                command_parts.append(pkg_config_flags)
        
        # Determine output name
        base_name = custom_output_name if custom_output_name else os.path.splitext(file_name)[0]
        
        if compile_type.startswith('.exe'):
            output_name = f'{base_name}_{target_arch}.exe'
        elif compile_type == '.dll':
            output_name = f'{base_name}.dll'
        elif compile_type == '.lib':
            output_name = f'{base_name}.lib'
        elif compile_type == '.obj':
            output_name = f'{base_name}.o'
        elif compile_type == '.so':
            output_name = f'{base_name}.so'
        else:
            output_name = base_name
            
        # Add output flag
        command_parts.extend(['-o', f"'{output_path}{output_name}'"])
        
        # Add input file (quoted like in main.dart)
        command_parts.append(f"'{os.path.basename(file_name)}'")
        
        return ' '.join(command_parts)
        
    def copy_command(self):
        command = self.command_display.toPlainText()
        if command:
            clipboard = QApplication.clipboard()
            clipboard.setText(command)
            QMessageBox.information(self, 'Copied', 'Command copied to clipboard!')
            
    def save_changes(self):
        current_item = self.file_list.currentItem()
        if not current_item:
            QMessageBox.warning(self, 'Warning', 'Please select a file first!')
            return
            
        file_name = current_item.text()
        
        # Get selected packages
        selected_packages = []
        if hasattr(self, 'package_list_view'):
            selected_indexes = self.package_list_view.selectionModel().selectedIndexes()
            selected_packages = [self.package_list_view.model().data(i, Qt.DisplayRole) for i in selected_indexes]
                    
        settings = {
            'compileOrder': self.compile_order.value(),
            'compiler': self.compiler_combo.currentText(),
            'architecture': self.architecture_combo.currentText(),
            'compileType': self.compile_type_combo.currentText(),
            'outputPath': self.output_path_input.text(),
            'customOutputName': self.custom_output_name_input.text(),
            'languageStandard': self.language_standard_combo.currentText(),
            'packages': selected_packages
        }
        
        self.config['fileSettings'][file_name] = settings
        
        with open(self.config_file, 'w') as fp:
            json.dump(self.config, fp, indent=2)
            
        QMessageBox.information(self, 'Success', f'Settings for {file_name} saved successfully!')
        
def parse_arguments():
    if len(sys.argv) < 2:
        print('Usage: python config_editor.py <working_directory> [msys2_path]')
        sys.exit(1)
        
    working_directory = sys.argv[1]
    msys2_path = sys.argv[2] if len(sys.argv) > 2 else None
    
    return working_directory.rstrip('/\\'), msys2_path.rstrip('/\\') if msys2_path else None

if __name__ == '__main__':
    app = QApplication(sys.argv)
    
    working_directory, msys2_path = parse_arguments()
    editor = ConfigEditor(working_directory, msys2_path)
    editor.show()
    
    sys.exit(app.exec_())

