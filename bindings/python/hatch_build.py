import os
import platform
import shutil
import subprocess
from itertools import chain
from pathlib import Path

from hatchling.builders.hooks.plugin.interface import BuildHookInterface

PARENT_DIR = Path(__file__).parent
SOURCE_DIR = PARENT_DIR.parents[1] / "cpp-bindings-test"
SDIST_SOURCE_DIR = PARENT_DIR / "lib-cpp-bindings-test"


class CustomBuildHook(BuildHookInterface):
    def initialize(self, version, build_data):
        is_sdist_build = SDIST_SOURCE_DIR.is_dir()
        source_dir = SDIST_SOURCE_DIR if is_sdist_build else SOURCE_DIR

        if os.environ.get("CI"):
            return

        print(f"building '{SOURCE_DIR.name}' library ...")

        target_dir = PARENT_DIR / "cpp-bindings-test" / "lib"
        target_dir.mkdir(exist_ok=True)

        if shutil.which("nix") and not is_sdist_build:
            subprocess.run(["nix", "build"], cwd=source_dir)
            out_dir = source_dir / "result" / "lib"
        else:
            out_dir = source_dir / "build"
            if out_dir.exists():
                shutil.rmtree(out_dir)
            out_dir.mkdir()

            generator = ["-G", "Visual Studio 17 2022"] if platform.system() == "Windows" else []
            subprocess.run(
                ["cmake", "-B", out_dir.name, "-DTESTING=off", *generator], cwd=source_dir
            )
            subprocess.run(
                ["cmake", "--build", out_dir.name, "--config", "Release"], cwd=source_dir
            )

        for path in chain(*(out_dir.glob(f"*.{ext}") for ext in ["so", "dll", "dylib"])):
            if (target_path := target_dir / path.name).is_file():
                target_path.unlink()
            shutil.copy(path, target_path)
