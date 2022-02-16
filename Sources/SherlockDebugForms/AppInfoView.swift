import SwiftUI

/// Screen for presenting Application-level information, e.g. App name, build version, bundler-identifier.
public struct AppInfoView: View
{
    @State public private(set) var searchText: String = ""

    public init() {}

    public var body: some View
    {
        SherlockForm(searchText: $searchText) {
            AppInfoSectionsView(searchText: searchText)
        }
        .formCellCopyable(true)
        .navigationTitle("App Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// AppInfo `Section`s, useful for presenting search results from ancestor screens.
public struct AppInfoSectionsView: View, SherlockView
{
    public let searchText: String
    private let sectionHeader: (String) -> String

    public init(
        searchText: String,
        sectionHeader: @escaping (String) -> String = { $0 }
    )
    {
        self.searchText = searchText
        self.sectionHeader = sectionHeader
    }

    public var body: some View
    {
        Section {
            textCell(title: "App Name", value: Application.current.appName)
            textCell(title: "Version", value: Application.current.version)
            textCell(title: "Build", value: Application.current.build)
            textCell(title: "Bundle ID", value: Application.current.bundleIdentifier)
            textCell(title: "App Size", value: Application.current.size)
            textCell(title: "Locale", value: Application.current.locale)
            textCell(title: "Localization", value: Application.current.preferredLocalizations)
            textCell(title: "TestFlight?", value: Application.current.isTestFlight)
        } header: {
            sectionHeaderView(sectionHeader(""))
        }
    }
}
