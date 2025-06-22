# watch.zig

`watch <executable> [..args]`

Linux executable watcher and runner:

1. Runs the executable (looks in PATH or use relative or absolute path).

2. On file change sends SIGTERM to process and waits for exit then starts it again.

# Install

`git clone https://github.com/e3dio/watch.zig`

`cd watch.zig`

`zig build -p ~/.local`

# Usage

When developing a project you can build and watch the src files:

`zig build --watch`

`zig build --watch -p ~/.local`

then watch the executable for fast development:

`watch <executable> [..args]`
