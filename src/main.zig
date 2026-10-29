const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    // Home directory
    const home = init.environ_map.get("HOME") orelse
        return error.HomeNotFound;

    // Directories
    const fromdir = try std.fmt.allocPrint(gpa, "{s}/Downloads", .{home});
    defer gpa.free(fromdir);

    const todir = try std.fmt.allocPrint(gpa, "{s}/.local/app", .{home});
    defer gpa.free(todir);

    const bindir = try std.fmt.allocPrint(gpa, "{s}/.local/bin", .{home});
    defer gpa.free(bindir);

    try std.Io.Dir.createDirPath(.cwd(), io, todir);
    try std.Io.Dir.createDirPath(.cwd(), io, bindir);

    var dir = try std.Io.Dir.cwd().openDir(io, fromdir, .{ .iterate = true });
    defer dir.close(io);


    const delimiter = '-';
    var iterator = dir.iterate();
    var found_any = false;


    while (try iterator.next(io)) |entry| {
        if (entry.kind != .file) continue;

        // Find AppImage files
        if (std.mem.endsWith(u8, entry.name, ".AppImage")) {
            found_any = true;

            // Get the application name
            const basename = entry.name[0 .. entry.name.len - ".AppImage".len];

            const name = if (std.mem.indexOfScalar(u8, basename, delimiter)) |index|
                basename[0..index]
            else
                basename;

            // Create the new filename
            const appname = try std.fmt.allocPrint(gpa, "{s}.AppImage", .{name});
            defer gpa.free(appname);

            // Get the original file path
            const fromfile = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ fromdir, entry.name });
            defer gpa.free(fromfile);

            // Get the destination file path
            const tofile = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ todir, appname });
            defer gpa.free(tofile);

            // Convert name to lowercase
            const linkname = try std.ascii.allocLowerString(gpa, name);
            defer gpa.free(linkname);

            // Get the symlink path
            const tobin = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ bindir, linkname });
            defer gpa.free(tobin);


            // Move the AppImage file
            try std.Io.Dir.renameAbsolute(fromfile, tofile, io);

            // Open the moved file
            var file = try std.Io.Dir.openFileAbsolute(io, tofile, .{});
            defer file.close(io);

            // Make the file executable
            try file.setPermissions(io, std.Io.File.Permissions.fromMode(0o755));


            // Remove existing link
            if (std.Io.Dir.accessAbsolute(io, tobin, .{})) |_| {
                try std.Io.Dir.deleteFileAbsolute(io, tobin);
            } else |_| {}

            // Create a symlink in PATH
            try std.Io.Dir.symLinkAbsolute(io, tofile, tobin, .{});
        }
    }

    // Report if no AppImage files were found
    if (!found_any) {
        std.debug.print("AppImage is not found.\n", .{});
    }
}
