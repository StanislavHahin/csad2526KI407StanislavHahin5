# csad2526KI407StanislavHahin5

Minimal C++ project with a small `math_operations` library and GoogleTest unit tests.

Quick commands (Linux/macOS/WSL):

```bash
mkdir -p build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release --parallel
ctest --output-on-failure -C Release
```

On Windows (cmd.exe):

```bat
mkdir build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
```

CI helpers: `ci.sh` (POSIX) and `ci.bat` (Windows) run configure, build and tests.
# csad2526KI407StanislavHahin5