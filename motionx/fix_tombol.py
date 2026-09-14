import re
path = "/workspaces/Motion-X/motionx/lib/editor_screen.dart"
with open(path, "r") as f:
    c = f.read()

# Masukkan parameter teks ke tombol Transform dan Hapus
c = c.replace("_dock(Icons.transform, _openTr)", "_dock(Icons.transform, 'Transform', _openTr)")
c = c.replace("_dock(Icons.delete, () {", "_dock(Icons.delete, 'Hapus', () {")
c = re.sub(r",\s*title:\s*['\"].*?['\"]", "", c)

with open(path, "w") as f:
    f.write(c)
print("Parameter tombol sudah diperbaiki!")
