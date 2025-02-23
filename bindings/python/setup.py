import os
from pathlib import Path

from cmake_build_extension import BuildExtension, CMakeExtension, GitSdistFolder
from setuptools import setup

CMAKE_DIRECTORY = Path(__file__).parents[2].absolute()

cmake_options = []
if os.environ.get("CI"):
    cmake_options.append("-DTESTING=off")

setup(
    name="cpp_bindings_test",
    ext_modules=[
        CMakeExtension(
            name="cpp-bindings-test",
            source_dir=str(CMAKE_DIRECTORY),
            cmake_configure_options=cmake_options,
        ),
    ],
    cmdclass={
        "sdist": GitSdistFolder,
        "build_ext": BuildExtension,
    },
)
