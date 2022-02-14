import Foundation

extension Helper
{
    public static func deleteAllFilesAndCaches() throws
    {
        try deleteAllCaches()

        try deleteDirectoryContents(at: .library)
        try deleteDirectoryContents(at: .applicationSupport)
        try deleteDirectoryContents(at: .document)
    }

    public static func deleteAllCaches() throws
    {
        URLCache.shared.removeAllCachedResponses()

        try deleteDirectoryContents(at: .caches)
        try deleteDirectoryContents(at: .tmp)
    }

    public static func deleteDirectoryContents(at directory: AppleDirectory) throws
    {
        try deleteDirectoryContents(atPath: directory.path)
    }

    // MARK: - Private

    private static func deleteDirectoryContents(atPath path: String) throws
    {
        let subdirectories = try FileManager.default.contentsOfDirectory(atPath: path)
        for subdirectory in subdirectories {
            let deletingURL = URL(fileURLWithPath: path).appendingPathComponent(subdirectory)
            do {
                try FileManager.default.removeItem(at: deletingURL)
                // print("[SUCCESS] deleteDirectoryContents at \(deletingURL)")
            }
            catch {
#if DEBUG
                print("[ERROR] deleteDirectoryContents:", error, "at \(deletingURL)")
#endif
            }
        }
    }
}
