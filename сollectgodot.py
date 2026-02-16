import os

def collect_godot_files(folder_path, output_filename="collected_godot_content.txt"):
    """
    Собирает содержимое файлов .gd и .tscn из ТЕКУЩЕЙ папки и всех вложенных,
    и записывает его в один текстовый файл.
    """
    try:
        # Получаем абсолютный путь к папке
        abs_folder_path = os.path.abspath(folder_path)
        print(f"Сканирование папки: {abs_folder_path}")

        file_count = 0

        # Создаем или открываем файл для записи
        with open(output_filename, 'w', encoding='utf-8') as outfile:
            # os.walk рекурсивно проходит по всем папкам
            for root, dirs, files in os.walk(abs_folder_path):
                
                # Игнорируем папку .godot (системный кэш), чтобы не мусорить
                if '.godot' in dirs:
                    dirs.remove('.godot')

                for file in files:
                    # Проверяем расширение файла
                    if file.endswith(('.gd', '.tscn','.tres')):
                        file_path = os.path.join(root, file)
                        # Вычисляем относительный путь для красивого заголовка
                        relative_path = os.path.relpath(file_path, abs_folder_path)
                        
                        print(f"  Чтение: {relative_path}")
                        file_count += 1
                        
                        try:
                            with open(file_path, 'r', encoding='utf-8') as infile:
                                outfile.write(f"--- Начало файла: {relative_path} ---\n")
                                outfile.write(infile.read())
                                outfile.write(f"\n--- Конец файла: {relative_path} ---\n\n")
                        except Exception as e:
                            outfile.write(f"--- Ошибка чтения файла: {relative_path} ---\n")
                            outfile.write(f"Ошибка: {e}\n\n")
                            print(f"    Ошибка при чтении файла {file_path}: {e}")

        print(f"\nГотово! Собрано файлов: {file_count}")
        print(f"Результат записан в: {output_filename}")

    except FileNotFoundError:
        print(f"Ошибка: Папка '{folder_path}' не найдена.")
    except Exception as e:
        print(f"Произошла ошибка: {e}")

if __name__ == "__main__":
    # os.getcwd() возвращает текущую рабочую директорию
    project_folder = os.getcwd()
    
    output_file = "godot_project_content.txt"

    collect_godot_files(project_folder, output_file)
    
    # Чтобы консоль не закрывалась сразу (если запускаешь двойным кликом)
    input("\nНажмите Enter, чтобы выйти...")
