import SwiftUI

public struct AppInfoView: View, SherlockView
{
    @State public var searchText: String = ""

    public init() {}

    public var body: some View
    {
        SherlockForm(searchText: $searchText) {
            Section {
                _body
            }
        }
        .formCellCopyable(true)
        .navigationTitle("App Info")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var _body: some View
    {
        textCell(title: "App Name", value: Application.current.appName)
        textCell(title: "Version", value: Application.current.version)
        textCell(title: "Build", value: Application.current.build)
        textCell(title: "Bundle ID", value: Application.current.bundleIdentifier)
        textCell(title: "App Size", value: Application.current.size)
        textCell(title: "Locale", value: Application.current.locale)
        textCell(title: "Localization", value: Application.current.preferredLocalizations)
        textCell(title: "TestFlight?", value: Application.current.isTestFlight)
    }
}
