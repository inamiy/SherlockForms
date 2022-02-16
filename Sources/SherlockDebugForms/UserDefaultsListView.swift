import SwiftUI
import SherlockForms

/// UserDefaults viewer.
/// - Todo: Make editable.
public struct UserDefaultsListView: View
{
    @State private var searchText: String = ""

    private let userDefaults: UserDefaults

    /// Custom list filtering.
    private let listFilter: ListFilter?

    private let maxCellHeight: CGFloat
    private let maxRecentlyUsedCount: Int

    public init(
        userDefaults: UserDefaults = .standard,
        listFilter: ListFilter? = nil,
        maxCellHeight: CGFloat = 100,
        maxRecentlyUsedCount: Int = 3
    )
    {
        self.userDefaults = userDefaults
        self.listFilter = listFilter
        self.maxCellHeight = maxCellHeight
        self.maxRecentlyUsedCount = maxRecentlyUsedCount
    }

    public var body: some View
    {
        SherlockForm(searchText: $searchText) {
            UserDefaultsListSectionsView(
                searchText: searchText,
                userDefaults: userDefaults,
                listFilter: listFilter,
                maxCellHeight: maxCellHeight,
                maxRecentlyUsedCount: maxRecentlyUsedCount
            )
        }
        .navigationTitle("UserDefaults")
        .navigationBarTitleDisplayMode(.inline)
    }

    public typealias ListFilter = (_ searchText: String, _ keywords: [String]) -> Bool
}

/// UserDefaults `Section`s, useful for presenting search results from ancestor screens.
@MainActor
public struct UserDefaultsListSectionsView: View, SherlockView
{
    public let searchText: String

    @State private var keyValues: [KeyValue] = []

    @AppStorage("com.inamiy.SherlockForms.UserDefaults.recently-used-keys")
    private var recentlyUsedKeys: Strings = .init()

    @State private var presentingKey: String?

    private let userDefaults: UserDefaults

    /// Custom list filtering.
    private let listFilter: ListFilter?

    private let maxCellHeight: CGFloat
    private let maxRecentlyUsedCount: Int

    private let sectionHeader: (String) -> String

    @Environment(\.showHUD)
    private var showHUD: (HUDMessage) -> Void

    public init(
        searchText: String,
        userDefaults: UserDefaults = .standard,
        listFilter: ListFilter? = nil,
        maxCellHeight: CGFloat = 100,
        maxRecentlyUsedCount: Int = 3,
        sectionHeader: @escaping (String) -> String = { $0 }
    )
    {
        self.searchText = searchText
        self.userDefaults = userDefaults

        self.keyValues = UserDefaults.standard.dictionaryRepresentation()
            .sorted(by: { $0.0 < $1.0 })

        self.listFilter = listFilter
        self.maxCellHeight = maxCellHeight
        self.maxRecentlyUsedCount = maxRecentlyUsedCount
        self.sectionHeader = sectionHeader
    }

    public var body: some View
    {
        Group {
            if !recentlyUsedKeys.strings.isEmpty && searchText.isEmpty && maxRecentlyUsedCount > 0 {
                Section {
                    recentlyUsedKeyValuesView
                } header: {
                    sectionHeaderView(sectionHeader("Recent"))
                }
            }

            Section {
                allKeyValuesView
            } header: {
                sectionHeaderView(sectionHeader("All"))
            }
        }
        .sheet(unwrapping: $presentingKey) { keyBinding in
            let key = keyBinding.wrappedValue
            if let index = keyValues.firstIndex(where: { $0.key == key }) {
                UserDefaultsItemView(keyValue: $keyValues[index])
            }
        }
    }

    @ViewBuilder
    private var recentlyUsedKeyValuesView: some View
    {
        let recentKeyValues: [KeyValue] = recentlyUsedKeys.strings.reversed()
            .compactMap { key in
                keyValues.first(where: { $0.key == key })
            }

        keyValuesView(keyValues: recentKeyValues)
    }

    @ViewBuilder
    private var allKeyValuesView: some View
    {
        keyValuesView(keyValues: keyValues)
    }

    @ViewBuilder
    private func keyValuesView(keyValues: [KeyValue]) -> some View
    {
        ForEach(keyValues, id: \.key) { key, value in
            textCell(title: key, value: value)
                .formCellContentModifier { cellContent in
                    // WARNING:
                    // `formCellContentModifier` is required for custom `contextMenu` attachment.
                    // If below SwiftUI-method-chain is attached directly to `textCell` instead of `cellContent`,
                    // malformed search result will appear.
                    cellContent
                        .frame(maxHeight: maxCellHeight)
                        .contentShape(Rectangle()) // Improves tap for empty space.
                        .onTapGesture {
                            // copyAsString(value)
                            showDetail(key: key)
                        }
                        .contextMenu {
                            Button { copyAsString(key) } label: {
                                Label("Copy Key", systemImage: "doc.on.doc")
                            }

                            Button { copyAsString(value) } label: {
                                Label("Copy Value", systemImage: "doc.on.doc")
                            }

                            Button { deleteKey(key) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
        }
    }

    public func canShowCell(keywords: [String]) -> Bool
    {
        if let listFilter = listFilter {
            return listFilter(searchText, keywords)
        }

        for keyword in keywords {
            if searchText.isEmpty || keyword.lowercased().contains(searchText.lowercased()) {
                return true
            }
        }
        return false
    }

    private func copyAsString(_ value: Value)
    {
        let string = String(describing: value)

        UIPasteboard.general.string = string

        showHUD(
            .init(
                message: "Copied \"\(string.truncated(maxCount: 50))\"",
                duration: 2,
                alignment: .bottom
            )
        )
    }

    private func deleteKey(_ key: String)
    {
        userDefaults.removeObject(forKey: key)

        for i in keyValues.indices.reversed() where keyValues[i].key == key {
            keyValues.remove(at: i)
        }

        showHUD(
            .init(
                message: "Deleted \"\(key.truncated(maxCount: 50))\"",
                duration: 2,
                alignment: .bottom
            )
        )
    }

    private func showDetail(key: String)
    {
        // Present modally.
        presentingKey = key

        Task {
            // Wait for modal animation.
            try await Task.sleep(nanoseconds: 300_000_000)

            // Then, update `recentlyUsedKeys`.
            if maxRecentlyUsedCount > 0 {
                await MainActor.run {
                    var keys = recentlyUsedKeys.strings
                    keys.removeAll(where: { $0 == key })
                    keys = Array(keys.suffix(maxRecentlyUsedCount - 1))
                    keys.append(key)
                    recentlyUsedKeys.strings = keys
                }
            }
        }
    }

    public typealias Key = String
    public typealias Value = Any
    public typealias KeyValue = (key: Key, value: Value)
    public typealias ListFilter = UserDefaultsListView.ListFilter
}

// MARK: - Strings

/// `@AppStorage`-persistable keys.
private struct Strings: Codable
{
    var strings: [String] = []
}

extension Strings: RawRepresentable
{
    public init?(rawValue: String)
    {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([String].self, from: data)
        else {
            return nil
        }
        self.strings = result
    }

    public var rawValue: String
    {
        guard let data = try? JSONEncoder().encode(self.strings),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
