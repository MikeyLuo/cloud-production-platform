from pathlib import Path
import shutil
import subprocess
import sys
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


root = Path(__file__).resolve().parents[1]
build_dir = root / ".build"
package_dir = build_dir / "lambda"
archive_path = build_dir / "visitor-counter.zip"

if package_dir.exists():
    shutil.rmtree(package_dir)

package_dir.mkdir(parents=True, exist_ok=True)

subprocess.run(
    [
        sys.executable,
        "-m",
        "pip",
        "install",
        "--requirement",
        str(root / "backend" / "requirements.txt"),
        "--target",
        str(package_dir),
        "--platform",
        "manylinux2014_x86_64",
        "--implementation",
        "cp",
        "--python-version",
        "3.13",
        "--only-binary=:all:",
        "--no-compile",
    ],
    check=True,
)

shutil.copy2(
    root / "backend" / "visitor_counter.py",
    package_dir / "visitor_counter.py",
)

with ZipFile(archive_path, "w", compression=ZIP_DEFLATED) as archive:
    for file in sorted(package_dir.rglob("*")):
        if file.is_file():
            entry = ZipInfo(file.relative_to(package_dir).as_posix())
            entry.compress_type = ZIP_DEFLATED
            entry.create_system = 3
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, file.read_bytes())

print(f"Created {archive_path}")