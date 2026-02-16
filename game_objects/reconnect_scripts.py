import os
import re

def update_tscn_file(tscn_path, project_root):
    """
    Updates the script paths in a single .tscn file.
    Assumes scripts are now in the same folder as the .tscn file,
    with the same filename but .gd extension.
    """
    with open(tscn_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex to find [ext_resource type="Script" ...]
    def replace_script_path(match):
        resource_str = match.group(0)
        # Find the path="..." part
        path_match = re.search(r'path="([^"]+)"', resource_str)
        if path_match:
            old_path = path_match.group(1)
            # Extract the script filename (e.g., Map.gd)
            script_filename = os.path.basename(old_path)
            # Get relative dir from project root to tscn's folder
            tscn_dir = os.path.dirname(tscn_path)
            rel_dir = os.path.relpath(tscn_dir, project_root)
            # Build new path: res://rel_dir/script.gd (or res://script.gd if in root)
            new_rel_path = rel_dir.replace('\\', '/') if rel_dir != '.' else ''
            new_path = f"res://{new_rel_path}/{script_filename}" if new_rel_path else f"res://{script_filename}"
            # Replace the old path in the string
            new_resource_str = resource_str.replace(old_path, new_path)
            return new_resource_str
        return resource_str

    # Apply replacement to all script ext_resources
    updated_content = re.sub(r'\[ext_resource type="Script"[^]]*\]', replace_script_path, content)

    # Write back to file
    with open(tscn_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)

def main(project_root='.'):
    """
    Walks through the project root and subfolders, updating all .tscn files.
    """
    for root_dir, _, files in os.walk(project_root):
        for filename in files:
            if filename.endswith('.tscn'):
                tscn_path = os.path.join(root_dir, filename)
                print(f"Updating: {tscn_path}")
                update_tscn_file(tscn_path, project_root)

if __name__ == "__main__":
    # Run from the project root
    main()
