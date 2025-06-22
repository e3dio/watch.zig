const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allo = gpa.allocator();

pub fn main() !void {
	const args = try std.process.argsAlloc(allo);
	const exe_name = std.fs.path.basename(args[1]);

	const which = try std.process.Child.run(.{ .allocator = allo, .argv = &.{ "which", args[1] } }); // path of exe
	if (which.stdout.len < 2) std.process.fatal("[watch] - file not found: {s}", .{args[1]});
	const exe_path = which.stdout[0..which.stdout.len-1];
	args[1] = try allo.dupeZ(u8, exe_path); // null term arg

	const fan_fd = try std.posix.fanotify_init(.{ .CLOEXEC = true, .REPORT_NAME = true, .REPORT_DIR_FID = true, .REPORT_FID = true, .REPORT_TARGET_FID = true }, 0);
	try std.posix.fanotify_mark(fan_fd, .{ .ADD = true }, .{ .CLOSE_WRITE = true, .MOVED_TO = true }, 0, std.fs.path.dirname(exe_path).?);
	var events_buf: [256 + 4096]u8 = undefined;

	while (true) { // run and watch for file change
		var child = std.process.Child.init(args[1..], allo); // start process
		try child.spawn();

		blk: while (true) { // watch loop - code from std/Build/Watch.zig
			var len = try std.posix.read(fan_fd, &events_buf);
			var meta: [*]align(1) std.os.linux.fanotify.event_metadata = @ptrCast(&events_buf);
			while (len >= 24 and meta[0].event_len >= 24 and meta[0].event_len <= len) : ({ // 24 = @sizeOf(event_metadata)
				len -= meta[0].event_len;
				meta = @ptrCast(@as([*]u8, @ptrCast(meta)) + meta[0].event_len);
			}) {
				const fid: *align(1) std.os.linux.fanotify.event_info_fid = @ptrCast(meta + 1);
				const file_handle: *align(1) std.os.linux.file_handle = @ptrCast(&fid.handle);
				const file_name_z: [*:0]u8 = @ptrCast((&file_handle.f_handle).ptr + file_handle.handle_bytes);
				const file_name = std.mem.span(file_name_z);
				if (std.mem.eql(u8, file_name, exe_name)) break :blk;
			}
		}

		std.debug.print("\n[watch] - restarting \"{s}\"..\n\n", .{exe_name}); // restart
		try std.posix.kill(child.id, std.c.SIG.TERM);
		_ = try child.wait();
	}
}
