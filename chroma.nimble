# Package
version = "0.1.0"
author = "Andre von Houck"
description = "Everything you want to do with colors"
license = "MIT"

srcDir = "src"

# Deps
requires "nim >= 1.0.0"
requires "mddoc >= 0.0.3"

task test, "run all tests":
  exec "nim c -r tests/test_colors.nim"
