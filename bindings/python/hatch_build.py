import os
import platform
import shutil
import subprocess
from itertools import chain
from pathlib import Path
from sysconfig import get_platform
from tempfile import gettempdir
from zipfile import ZipFile

from auditwheel.wheel_abi import analyze_wheel_abi
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

        lib_paths = list(chain(*(out_dir.glob(f"*.{ext}") for ext in ["so", "dll", "dylib"])))
        for lib_path in lib_paths:
            if (target_path := target_dir / lib_path.name).is_file():
                target_path.unlink()
            shutil.copy(lib_path, target_path)

        dummy_wheel_path = Path(gettempdir()) / "dummy.whl"
        with ZipFile(dummy_wheel_path, "w", strict_timestamps=False) as zip_file:
            records_str = ""
            for lib_path in lib_paths:
                zip_file.write(lib_path, lib_path.name)
                records_str += f"{lib_path.name},,\n"
            zip_file.writestr("dummy.dist-info/RECORD", records_str)
        wheel_info = analyze_wheel_abi(None, None, dummy_wheel_path, frozenset(), False, False)

        platform_tag = get_platform().replace("-", "_").replace(".", "_")
        if wheel_info.external_refs[wheel_info.policies.lowest.name].libs:
            platform_tag = f"{wheel_info.overall_policy.name}_{platform_tag}"
        build_data["tag"] = f"py3-none-{platform_tag}"
