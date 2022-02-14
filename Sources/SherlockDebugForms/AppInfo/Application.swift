import Foundation

/// Originally from https://github.com/noppefoxwolf/DebugMenu
public class Application {
    public static var current: Application = .init()

    public var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }

    public var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    public var build: String {
        Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    }

    public var buildNumber: Int {
        Int(build) ?? 0
    }

    public var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    public var locale: String {
        Locale.current.identifier
    }

    public var preferredLocalizations: String {
        Bundle.main.preferredLocalizations.joined(separator: ",")
    }

    public var isTestFlight: Bool {
#if DEBUG
        return false
#else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
#endif
    }

    public var size: String {
        let byteCount = try? getByteCount()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: Int64(byteCount ?? 0))
    }
}

extension Application {
    public func getByteCount() throws -> UInt64 {
        let bundlePath = Bundle.main.bundlePath
        let documentPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )[0]
        let libraryPath = NSSearchPathForDirectoriesInDomains(
            .libraryDirectory,
            .userDomainMask,
            true
        )[0]
        let tmpPath = NSTemporaryDirectory()
        return try [bundlePath, documentPath, libraryPath, tmpPath].map(getFileSize(atDirectory:))
            .reduce(0, +)
    }

    internal func getFileSize(atDirectory path: String) throws -> UInt64 {
        let files = try FileManager.default.subpathsOfDirectory(atPath: path)
        var fileSize: UInt64 = 0
        for file in files {
            let attributes = try FileManager.default.attributesOfItem(atPath: "\(path)/\(file)")
            fileSize += attributes[.size] as! UInt64
        }
        return fileSize
    }
}
