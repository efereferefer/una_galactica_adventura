import os
import sys

# Настройки замен. Порядок важен, хотя в данном случае пересечений нет.
# Мы меняем Fleet -> Ship во всех вариациях регистра.
REPLACEMENTS = [
    ("ShipState", "ShipData"),  # PascalCase (FleetData -> ShipData)
]

# Расширения файлов, внутри которых мы будем менять текст.
# Картинки и звуки (.png, .wav) трогать нельзя, иначе они сломаются.
TEXT_EXTENSIONS = {'.gd', '.tscn', '.tres', '.txt', '.json', '.md', '.yml', '.cfg'}

def replace_text_in_file(file_path):
    """Открывает файл, меняет текст и сохраняет обратно, если были изменения."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        print(f"Skipping binary or unknown encoding: {file_path}")
        return

    new_content = content
    changes_made = False

    for old, new in REPLACEMENTS:
        if old in new_content:
            new_content = new_content.replace(old, new)
            changes_made = True

    if changes_made:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated content in: {file_path}")

def rename_fs_item(root_dir, item_name, is_dir=False):
    """Переименовывает файл или папку, если имя содержит искомые слова."""
    new_name = item_name
    for old, new in REPLACEMENTS:
        if old in new_name:
            new_name = new_name.replace(old, new)
    
    if new_name != item_name:
        old_path = os.path.join(root_dir, item_name)
        new_path = os.path.join(root_dir, new_name)
        
        # Проверка, чтобы не перезаписать существующий файл (маловероятно, но всё же)
        if os.path.exists(new_path):
            print(f"WARNING: Cannot rename {old_path} to {new_path}, target exists.")
        else:
            os.rename(old_path, new_path)
            type_label = "Directory" if is_dir else "File"
            print(f"Renamed {type_label}: {item_name} -> {new_name}")

def main():
    root_path = os.getcwd()
    print(f"Starting refactoring in: {root_path}")
    print("WARNING: Make sure you have a backup/git commit before proceeding.")
    confirm = input("Type 'yes' to continue: ")
    if confirm.lower() != 'yes':
        print("Aborted.")
        sys.exit()

    # Шаг 1: Проходим по всем файлам и меняем СОДЕРЖИМОЕ.
    # Это важно сделать до переименования файлов, чтобы пути внутри файлов (res://...)
    # обновились одновременно с планами на переименование файлов.
    for root, dirs, files in os.walk(root_path):
        # Исключаем папку .git и .godot (импорты пересоздадутся сами)
        if '.git' in root or '.godot' in root:
            continue
            
        for file in files:
            _, ext = os.path.splitext(file)
            if ext in TEXT_EXTENSIONS:
                file_path = os.path.join(root, file)
                replace_text_in_file(file_path)

    # Шаг 2: Переименовываем ФАЙЛЫ и ПАПКИ.
    # Используем topdown=False, чтобы сначала переименовать файлы внутри папок,
    # а только потом сами папки (иначе пути сломаются в процессе обхода).
    for root, dirs, files in os.walk(root_path, topdown=False):
        if '.git' in root or '.godot' in root:
            continue

        # Сначала файлы
        for file in files:
            rename_fs_item(root, file, is_dir=False)
        
        # Потом папки
        for dir_name in dirs:
            rename_fs_item(root, dir_name, is_dir=True)

    print("\nRefactoring complete!")
    print("Please reload the project in Godot.")
    print("Note: If Godot shows 'dependencies broken', click 'Fix Dependencies' or rely on the text replacement having fixed the paths.")

if __name__ == "__main__":
    main()
