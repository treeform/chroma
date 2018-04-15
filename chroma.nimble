# Package
version = "0.0.1"
author = "Andre von Houck"
description = "Everything you want to do with colors"
license = "MIT"

srcDir = "src"

# Deps
requires "nim >= 0.18.0"

# Tests
task test, "Runs the test suite":
  exec "nim c -r tests/test_colors"

task docs, "Generate docs":
  exec "nim doc2 --project src/chroma.nim; cp htmldocs/chroma.html docs/index.html"
