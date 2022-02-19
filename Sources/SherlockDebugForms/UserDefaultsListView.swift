import SwiftUI
import SherlockForms

/// UserDefaults viewer.
///
/// # Known issue
/// - After presenting `DatePicker`'s popup, `showDetail` doesn' work properly (possibly due to SwiftUI bug).
public struct UserDefaultsListView: View
{
    @State private var searchText: String = ""

    private let userDefaults: UserDefaults

    /// UserDefaults editable key-hints configuration to allow inline editing.
    private let editConfiguration: EditConfiguration

    /// Custom list filtering.
    private let listFilter: ListFilter?

    private let maxCellHeight: CGFloat
    private let maxRecentlyUsedCount: Int

    public init(
        userDefaults: UserDefaults = .standard,
        listFilter: ListFilter? = nil,
        editConfiguration: EditConfiguration = .init(),
        maxCellHeight: CGFloat = 100,
        maxRecentlyUsedCount: Int = 3
    )
    {
        self.userDefaults = userDefaults
        self.listFilter = listFilter
        self.editConfiguration = editConfiguration
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
                editConfiguration: editConfiguration,
                maxCellHeight: maxCellHeight,
                maxRecentlyUsedCount: maxRecentlyUsedCount
            )
        }
        .navigationTitle("UserDefaults")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Inner Types

    public typealias Key = String
    public typealias Value = Any
    public typealias KeyValue = (key: Key, value: Value)

    public typealias ListFilter = (_ searchText: String, _ keywords: [String]) -> Bool

    /// UserDefaults editable key-hints configuration to allow inline editing.
    public struct EditConfiguration
    {
        public var boolKeys: [Key]
        public var stringKeys: [Key]
        public var dateKeys: [Key]
        public var intKeys: [Key]
        public var doubleKeys: [Key]

        public init(
            boolKeys: [Key] = [],
            stringKeys: [Key] = [],
            dateKeys: [Key] = [],
            intKeys: [Key] = [],
            doubleKeys: [Key] = []
        )
        {
            self.boolKeys = boolKeys
            self.stringKeys = stringKeys
            self.dateKeys = dateKeys
            self.intKeys = intKeys
            self.doubleKeys = doubleKeys
        }
    }
}

/// UserDefaults `Section`s, useful for presenting search results from ancestor screens.
@MainActor
public struct UserDefaultsListSectionsView: View, SherlockView
{
    @StateObject private var notifier: UserDefaultsNotifier = .init()

    public let searchText: String

    @State private var keyValues: [KeyValue] = []

    @AppStorage("com.inamiy.SherlockForms.UserDefaults.recently-used-keys")
    private var recentlyUsedKeys: Strings = .init()

    @State private var presentingKey: String?

    private let userDefaults: UserDefaults

    private let editConfiguration: EditConfiguration

    /// Custom list filtering.
    private let listFilter: ListFilter?

    private let maxCellHeight: CGFloat
    private let maxRecentlyUsedCount: Int

    private let sectionHeader: (String) -> String

    @Environment(\.showHUD)
    private var showHUD: @MainActor (HUDMessage) -> Void

    public init(
        searchText: String,
        userDefaults: UserDefaults = .standard,
        listFilter: ListFilter? = nil,
        editConfiguration: EditConfiguration = .init(),
        maxCellHeight: CGFloat = 100,
        maxRecentlyUsedCount: Int = 3,
        sectionHeader: @escaping (String) -> String = { $0 }
    )
    {
        self.searchText = searchText
        self.userDefaults = userDefaults

        self.keyValues = userDefaults.getKeyValues()

        self.listFilter = listFilter
        self.editConfiguration = editConfiguration
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
        .onReceive(notifier.objectWillChange) { _ in
            keyValues = userDefaults.getKeyValues()
        }
        .sheet(unwrapping: $presentingKey) { keyBinding in
            let key = keyBinding.wrappedValue
            if let index = keyValues.firstIndex(where: { $0.key == key }) {
                let value = keyValues[index].value
                UserDefaultsItemView(key: key, value: value, userDefaults: userDefaults)
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
            if editConfiguration.boolKeys.contains(key) {
                if let bool = value as? Bool {
                    boolValueCell(key: key, bool: bool)
                }
                else {
                    defaultCell(key: key, value: value)
                }
            }
            else if editConfiguration.stringKeys.contains(key) {
                if let string = value as? String {
                    stringValueCell(key: key, string: string)
                }
                else {
                    defaultCell(key: key, value: value)
                }
            }
            else if editConfiguration.dateKeys.contains(key) {
                if let date_ = value as? Date,
                   let date = SherlockDate(date_)
                {
                    dateValueCell(key: key, date: date)
                }
                else if let string = value as? String,
                    let date = SherlockDate(rawValue: string)
                {
                    dateValueCell(key: key, date: date)
                }
                else {
                    defaultCell(key: key, value: value)
                }
            }
            else if editConfiguration.intKeys.contains(key) {
                if let int = value as? Int {
                    intValueCell(key: key, int: int)
                }
                else {
                    defaultCell(key: key, value: value)
                }
            }
            else if editConfiguration.doubleKeys.contains(key) {
                if let double = value as? Double {
                    doubleValueCell(key: key, double: double)
                }
                else {
                    defaultCell(key: key, value: value)
                }
            }
            else {
                defaultCell(key: key, value: value)
            }
        }
    }

    @ViewBuilder
    private func boolValueCell(key: Key, bool: Bool) -> some View
    {
        toggleCell(title: key, isOn: Binding(get: { bool }, set: { newValue in
            userDefaults.set(newValue, forKey: key)
            insertRecentlyUsedKey(key)
            self.keyValues = userDefaults.getKeyValues()
        }))
            .formCellContentModifier(contextMenuModifier(key: key, value: bool))
    }

    @ViewBuilder
    private func stringValueCell(key: Key, string: String) -> some View
    {
        textFieldCell(
            title: key,
            value: Binding(get: { string }, set: { newValue in
                userDefaults.set(newValue, forKey: key)
                insertRecentlyUsedKey(key)
                self.keyValues = userDefaults.getKeyValues()
            }),
            modify: {
                $0
                    .onTapGesture { /* Don't let wrapper view to steal this tap */ }
                    .frame(minWidth: 100, maxWidth: 200)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(4)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        )
            .formCellContentModifier(contextMenuModifier(key: key, value: string))
    }

    @ViewBuilder
    private func dateValueCell(key: Key, date: SherlockDate) -> some View
    {
        datePickerCell(
            title: key,
            selection: Binding(get: { date.date }, set: { newValue in
                let date = SherlockDate(newValue)

                userDefaults.set(date.rawValue, forKey: key)
                insertRecentlyUsedKey(key)
                self.keyValues = userDefaults.getKeyValues()
            }),
            displayedComponents: [.date, .hourAndMinute]
        )
            .formCellContentModifier(contextMenuModifier(key: key, value: date.rawValue))
    }

    @ViewBuilder
    private func intValueCell(key: Key, int: Int) -> some View
    {
        textFieldCell(
            title: key,
            value: Binding(get: { "\(int)" }, set: { newValue in
                guard let int = Int(newValue) else { return }

                userDefaults.set(int, forKey: key)
                insertRecentlyUsedKey(key)
                self.keyValues = userDefaults.getKeyValues()
            }),
            modify: {
                $0
                    .onTapGesture { /* Don't let wrapper view to steal this tap */ }
                    .frame(minWidth: 100, maxWidth: 200)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        )
            .formCellContentModifier(contextMenuModifier(key: key, value: int))
    }

    @ViewBuilder
    private func doubleValueCell(key: Key, double: Double) -> some View
    {
        textFieldCell(
            title: key,
            value: Binding(get: { "\(double)" }, set: { newValue in
                guard let double = Double(newValue) else { return }

                userDefaults.set(double, forKey: key)
                insertRecentlyUsedKey(key)
                self.keyValues = userDefaults.getKeyValues()
            }),
            modify: {
                $0
                    .onTapGesture { /* Don't let wrapper view to steal this tap */ }
                    .frame(minWidth: 100, maxWidth: 200)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        )
            .formCellContentModifier(contextMenuModifier(key: key, value: double))
    }

    @ViewBuilder
    private func defaultCell(key: Key, value: Value) -> some View
    {
        textCell(title: key, value: value)
            .formCellContentModifier(contextMenuModifier(key: key, value: value))
    }

    private func contextMenuModifier(key: Key, value: Value) -> AnyViewModifier {
        AnyViewModifier { content in
            // WARNING:
            // `formCellContentModifier` is required for custom `contextMenu` attachment.
            // If below SwiftUI-method-chain is attached directly to `textCell` instead of `cellContent`,
            // malformed search result will appear.
            content
                .frame(maxWidth: .infinity, maxHeight: maxCellHeight)
                .contentShape(Rectangle()) // Improves tap for empty space.
                .onTapGesture {
                    if let firstResponder = UIView.currentFirstResponder() {
                        firstResponder.resignFirstResponder()
                    }
                    else {
                        showDetail(key: key)
                    }
                }
                .contextMenu {
                    Button { copyAsString(key) } label: {
                        Label("Copy Key", systemImage: "doc.on.doc")
                    }

                    Button { copyAsString(value) } label: {
                        Label("Copy Value", systemImage: "doc.on.doc")
                    }

                    Button { showDetail(key: key) } label: {
                        Label("Show Detail", systemImage: "doc.text.magnifyingglass")
                    }

                    Button { deleteKey(key) } label: {
                        Label("Delete", systemImage: "trash")
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
            insertRecentlyUsedKey(key)
        }
    }

    private func insertRecentlyUsedKey(_ key: String)
    {
        guard maxRecentlyUsedCount > 0 else { return }

        var keys = recentlyUsedKeys.strings
        keys.removeAll(where: { $0 == key })
        keys = Array(keys.suffix(maxRecentlyUsedCount - 1))
        keys.append(key)
        recentlyUsedKeys.strings = keys
    }

    public typealias Key = UserDefaultsListView.Key
    public typealias Value = UserDefaultsListView.Value
    public typealias KeyValue = UserDefaultsListView.KeyValue
    public typealias ListFilter = UserDefaultsListView.ListFilter
    public typealias EditConfiguration = UserDefaultsListView.EditConfiguration
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

// MARK: - Private

extension UserDefaults
{
    func getKeyValues() -> [UserDefaultsListView.KeyValue]
    {
        dictionaryRepresentation()
            .sorted(by: { $0.0 < $1.0 })
    }
}

private final class UserDefaultsNotifier : ObservableObject
{
    let objectWillChange = NotificationCenter.default
        .publisher(for: UserDefaults.didChangeNotification, object: nil)

    init() {}
}
