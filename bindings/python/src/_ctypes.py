import platform
from ctypes import CDLL, c_int
from pathlib import Path

LIB_EXTENSION = {"Windows": "dll", "Darwin": "dylib"}.get(platform.system(), "so")
LIBRARY_PATH = Path(__file__).parent / "lib" / f"libcpp-bindings-test.{LIB_EXTENSION}"

cpp_bindings_test = CDLL(LIBRARY_PATH)

hello = cpp_bindings_test.hello
hello.argtypes = [c_int]
hello.restype = c_int
