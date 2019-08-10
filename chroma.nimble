# Package
version = "0.0.1"
author = "Andre von Houck"
description = "Everything you want to do with colors"
license = "MIT"

srcDir = "src"

# Deps
requires "nim >= 0.18.0"

task test, "run all tests":
  exec "nim c -r tests/test_colors.nim"
