import Foundation

/// Apple-provided fixed directory path wrapper.
///
/// - SeeAlso : [File System Basics](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)
public struct AppleDirectory
{
    public let path: String

    internal init(_ directoryPath: String)
    {
        self.path = directoryPath
    }

    public init(_ directory: FileManager.SearchPathDirectory)
    {
        let expandTilde = true
        let directoryPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, expandTilde).first!
        self.init(directoryPath)
    }
}

// MARK: - Apple-provided fixed directory paths

extension AppleDirectory
{
    /// `$HOME`.
    ///
    /// Returns the path to either the user’s or application’s home directory, depending on the platform.
    /// In iOS, the home directory is the application’s sandbox directory.
    /// In macOS, it’s the application’s sandbox directory, or the current user’s home directory if the application isn’t in a sandbox.
    public static let home = AppleDirectory(NSHomeDirectory())

    /// `$HOME/Documents/`.
    ///
    /// Use this directory to store user-generated content.
    /// The contents of this directory can be made available to the user through file sharing;
    /// therefore, this directory should only contain files that you may wish to expose to the user.
    /// The contents of this directory are backed up by iTunes and iCloud.
    public static let document = AppleDirectory(.documentDirectory)

    /// `$HOME/Library/Application Support/`.
    ///
    /// Use this directory to store all app data files except those associated with the user’s documents.
    /// For example, you might use this directory to store app-created data files, configuration files, templates,
    /// or other fixed or modifiable resources that are managed by the app.
    /// An app might use this directory to store a modifiable copy of resources contained initially in the app’s bundle.
    /// A game might use this directory to store new levels purchased by the user and downloaded from a server.
    ///
    /// All content in this directory should be placed in a custom subdirectory whose name is that of your app’s bundle identifier or your company.
    ///
    /// In iOS, the contents of this directory are backed up by iTunes and iCloud.
    public static let applicationSupport = AppleDirectory(.applicationSupportDirectory)

    /// `$HOME/Library/`.
    ///
    /// This is the top-level directory for any files that are not user data files.
    /// You typically put files in one of several standard subdirectories.
    /// iOS apps commonly use the Application Support and Caches subdirectories; however, you can create custom subdirectories.
    ///
    /// Use the Library subdirectories for any files you don’t want exposed to the user.
    /// Your app should not use these directories for user data files.
    /// The contents of the Library directory (with the exception of the Caches subdirectory) are backed up by iTunes and iCloud.
    public static let library = AppleDirectory(.libraryDirectory)

    /// `$HOME/Library/Caches/`.
    ///
    /// Use the Library subdirectories for any files you don’t want exposed to the user.
    /// Your app should not use these directories for user data files.
    /// The contents of the Caches directory are NOT backed up by iTunes and iCloud.
    ///
    /// In iOS 5.0 and later, the system may delete the Caches directory on rare occasions when the system is very low on disk space.
    /// This will never occur while an app is running.
    /// However, be aware that restoring from backup is not necessarily the only condition under which the Caches directory can be erased.
    public static let caches = AppleDirectory(.cachesDirectory)

    /// `tmp/`.
    ///
    /// Use this directory to write temporary files that do not need to persist between launches of your app.
    /// Your app should remove files from this directory when they are no longer needed;
    /// however, the system may purge this directory when your app is not running.
    /// The contents of this directory are not backed up by iTunes or iCloud.
    public static let tmp = AppleDirectory(NSTemporaryDirectory())

    // FIXME: Add more.
}
