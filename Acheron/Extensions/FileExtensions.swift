extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select Windows 10 Disk Image"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["iso"]
        return runModal() == .OK ? urls.first : nil
    }
}
