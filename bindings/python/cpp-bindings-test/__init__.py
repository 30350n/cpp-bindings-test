__all__ = ["_ctypes", "hello"]

from . import _ctypes


def hello(num: int):
    _ctypes.hello(num)
