import SwiftUI
import SherlockDebugForms

/// NOTE: Each view that owns `SherlockForm` needs to conform to `SherlockView` protocol.
@MainActor
struct RootView: View, SherlockView
{
    /// NOTE:
    /// `searchText` is required for `SherlockView` protocol.
    /// This is the only requirement to define as `@State`, and pass it to `SherlockForm`.
    @State public private(set) var searchText: String = ""

    @AppStorage(UserDefaultsStringKey.username.rawValue)
    private var username: String = "John Appleseed"

    @AppStorage(UserDefaultsStringKey.email.rawValue)
    private var email: String = "john@example.com"

    @AppStorage(UserDefaultsStringKey.password.rawValue)
    private var password: String = "admin"

    @AppStorage(UserDefaultsStringKey.languageSelection.rawValue)
    private var languageSelection: String = Constant.languages[0]

    /// Index of `Constant.languages`.
    @AppStorage(UserDefaultsIntKey.languageIntSelection.rawValue)
    private var languageIntSelection: Int = 0

    @AppStorage(UserDefaultsStringKey.status.rawValue)
    private var status = Constant.Status.online

    @AppStorage(UserDefaultsBoolKey.lowPowerMode.rawValue)
    private var isLowPowerOn: Bool = false

    @AppStorage(UserDefaultsBoolKey.slowAnimation.rawValue)
    private var isSlowAnimation: Bool = false

    @AppStorage(UserDefaultsDoubleKey.speed.rawValue)
    private var speed: Double = 1.0

    @AppStorage(UserDefaultsDoubleKey.fontSize.rawValue)
    private var fontSize: Double = 10

    @AppStorage(UserDefaultsDateKey.birthday.rawValue)
    private var birthday: SherlockDate = .init()

    @AppStorage(UserDefaultsDateKey.alarm.rawValue)
    private var alarmDate: SherlockDate = .init()

    @AppStorage(UserDefaultsStringKey.testLongUserDefaults.rawValue)
    private var stringForTestingLongUserDefault: String = ""

    /// - Note:
    /// Attaching `.enableSherlockHUD(true)` to topmost view will allow using `showHUD`.
    /// See `SherlockHUD` module for more information.
    @Environment(\.showHUD)
    private var showHUD: @MainActor (HUDMessage) -> Void

    var body: some View
    {
        // NOTE:
        // `SherlockForm` and `xxxCell` is where all the search magic is happening!
        // Just treat `SherlockForm` as a normal `Form`, and use `Section` and plain SwiftUI views accordingly.
        SherlockForm(searchText: $searchText) {
            // Simple form cells.
            Section {
                // Customized form cell using `vstackCell`.
                // NOTE: Combination of `SherlockForm` and `ContainerCell` is the secret of `keyword`-based searching.
                customVStackCell

                // Built-in form cells (using `hstackCell` internally).
                // See `FormCells` source directory for more info.
                textCell(icon: Image(systemName: "person.fill"), title: "User", value: username)
                arrayPickerCell(icon: Image(systemName: "character.bubble"), title: "Language", selection: $languageSelection, values: Constant.languages)
                casePickerCell(icon: Image(systemName: "person.badge.clock"), title: "Status", selection: $status)
                toggleCell(icon: Image(systemName: "battery.25"), title: "Low Power Mode", isOn: $isLowPowerOn)
            } header: {
                Text("Simple form cells")
            } footer: {
                if searchText.isEmpty {
                    Text("Tip: Long-press cells to copy!")
                }
            }

            // More form cells
            Section {
                textFieldCell(icon: Image(systemName: "character.cursor.ibeam"), title: "Editable", value: $username) {
                    $0
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                textEditorCell(icon: Image(systemName: "character.cursor.ibeam"), title: "Multiline Editable", value: $username) {
                    $0
                        .multilineTextAlignment(.trailing)
                        .frame(maxHeight: 100)
                }

                // Array picker cell that uses `languageIntSelection` (index) as state.
                arrayPickerCell(
                    icon: Image(systemName: "filemenu.and.cursorarrow"),
                    title: "Int Picker",
                    selection: Binding(
                        get: { Constant.languages[languageIntSelection] },
                        set: { newValue in
                            guard let index = Constant.languages.firstIndex(of: newValue) else { return }
                            languageIntSelection = index
                        }
                    ),
                    values: Constant.languages
                )

                arrayPickerCell(
                    icon: Image(systemName: "filemenu.and.cursorarrow"),
                    title: "Async Picker",
                    selection: $languageSelection,
                    accessory: {
                        Text("Default")
                            .foregroundColor(.gray)
                        Spacer().frame(width: 8)
                        ProgressView()
                    },
                    action: {
                        // Simulating async work...
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        return Constant.languages
                    },
                    valueType: String.self
                )

                sliderCell(
                    icon: Image(systemName: "speedometer"),
                    title: "Speed",
                    value: $speed,
                    in: 0.5 ... 2.0,
                    step: 0.1,
                    maxFractionDigits: 1,
                    valueString: { "x\($0)" },
                    sliderLabel: { EmptyView() },
                    minimumValueLabel: { Image(systemName: "tortoise") },
                    maximumValueLabel: { Image(systemName: "hare") },
                    onEditingChanged: { print("onEditingChanged", $0) }
                )

                stepperCell(
                    icon: Image(systemName: "textformat.size"),
                    title: "Font Size",
                    value: $fontSize,
                    in: 8 ... 24,
                    step: 1,
                    maxFractionDigits: 0,
                    valueString: { "\($0) pt" }
                )

                datePickerCell(
                    icon: Image(systemName: "birthday.cake"),
                    title: "Birthday",
                    selection: $birthday.date,
                    in: .distantPast ... Date(),
                    displayedComponents: .date
                )

                datePickerCell(
                    icon: Image(systemName: "alarm"),
                    title: "Alarm",
                    selection: $alarmDate.date,
                    displayedComponents: [.hourAndMinute, .date]
                )
            } header: {
                Text("More form cells")
            }

            // NOTE:
            // `hstackCell` is useful for more customizable HStack
            // such as manually registering search keywords and configuring context-menu.
            //
            // Here, `hstackCell` is used with default configuration, which automatically hides
            // whenever search happens, and no context-menu is set.
            Section {
                hstackCell {
                    Text("Email").frame(width: 80, alignment: .leading)
                    Spacer(minLength: 16)
                    TextField("Input Email", text: $email)
                }

                hstackCell {
                    Text("Password").frame(width: 80, alignment: .leading)
                    Spacer(minLength: 16)
                    SecureField("Input Password", text: $password)
                }
            } header: {
                Text("HStack Cell (More customizable)")
            }

            // Navigation Link Cell (`navigationLinkCell`)
            Section {
                navigationLinkCell(
                    icon: Image(systemName: "person.fill"),
                    title: "UserDefaults",
                    destination: {
                        UserDefaultsListView(
                            editConfiguration: .init(
                                boolKeys: Array(UserDefaultsBoolKey.allCases.map(\.rawValue)),
                                stringKeys: Array(UserDefaultsStringKey.allCases.map(\.rawValue)),
                                dateKeys: Array(UserDefaultsDateKey.allCases.map(\.rawValue)),
                                intKeys: Array(UserDefaultsIntKey.allCases.map(\.rawValue)),
                                doubleKeys: Array(UserDefaultsDoubleKey.allCases.map(\.rawValue))
                            )
                        )
                    }
                )
                navigationLinkCell(
                    icon: Image(systemName: "app.badge"),
                    title: "App Info",
                    destination: { AppInfoView() }
                )
                navigationLinkCell(
                    icon: Image(systemName: "iphone"),
                    title: "Device Info",
                    destination: { DeviceInfoView() }
                )
                navigationLinkCell(icon: Image(systemName: "doc.richtext"), title: "Custom Page", destination: {
                    CustomView()
                })
                navigationLinkCell(icon: Image(systemName: "doc.richtext"), title: "Custom Page (Recursive)", destination: RootView.init)
                navigationLinkCell(icon: Image(systemName: "list.bullet"), title: "Simple List", destination: {
                    ListView()
                })
                navigationLinkCell(icon: Image(systemName: "list.bullet.indent"), title: "Nested List", destination: {
                    NestedListView()
                })
            } header: {
                Text("Navigation Link Cell")
            } footer: {
                if searchText.isEmpty {
                    Text("Tip: Custom page (even this page) is just a plain SwiftUI View.")
                }
            }

            // Buttons (`buttonCell`)
            Section {
                buttonCell(
                    icon: Image(systemName: "trash"),
                    title: "Reset UserDefaults",
                    action: {
                        Helper.deleteUserDefaults()
                        showHUD(.init(message: "Finished resetting UserDefaults"))
                    }
                )

                buttonCell(
                    icon: Image(systemName: "trash"),
                    title: "Delete Caches",
                    action: {
                        // Fake long task...
                        try await Task.sleep(nanoseconds: 1_000_000_000)

                        try? Helper.deleteAllCaches()
                        showHUD(.init(message: "Finished deleting caches"))
                    }
                )

                if #available(iOS 15.0, *) {
                    // `buttonCell` with `confirmationDialog`.
                    buttonDialogCell(
                        icon: Image(systemName: "trash"),
                        title: "Delete All Contents",
                        dialogTitle: nil,
                        dialogButtons: [
                            .init(title: "Delete All Contents", role: .destructive) {
                                // Fake long task...
                                try await Task.sleep(nanoseconds: 2_000_000_000)

                                try? Helper.deleteAllFilesAndCaches()
                                showHUD(.init(message: "Finished deleting all contents"))
                            },
                            .init(title: "Cancel", role: .cancel) {
                                print("Cancelled")
                            }
                        ]
                    )
                }
                else {
                    buttonCell(icon: Image(systemName: "person.fill"), title: "Delete All Contents", action: {
                        try? Helper.deleteAllFilesAndCaches()
                    })
                }
            } header: {
                Text("Buttons")
            } footer: {
                if searchText.isEmpty {
                    Text("Tip: Last button is ButtonDialog.")
                }
            }

            // Slow motion (`toggleCell`)
            Section {
                toggleCell(icon: Image(systemName: "figure.roll"), title: "Slow Animation", isOn: $isSlowAnimation)
                    .onChange(of: isSlowAnimation) { isSlowAnimation in
                        // Workaround:
                        // Immediately setting animation speed after `Toggle` change will cause
                        // its malformed UI, so add `sleep` to workaround (NOTE: 500 ms is not enough).
                        Task { @MainActor in
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            setAnimationSpeed(isSlowAnimation: isSlowAnimation)
                        }
                    }
                    .onAppear {
                        setAnimationSpeed(isSlowAnimation: isSlowAnimation)
                    }
            } header: {
                Text("Slow motion")
            }

            // Full-Text Search Result:
            // Show navigationLink's search results as well.
            if !searchText.isEmpty {
                UserDefaultsListSectionsView(
                    searchText: searchText,
                    maxRecentlyUsedCount: 0,
                    sectionHeader: { sectionHeader(prefixes: "UserDefaults", title: $0) }
                )
                AppInfoSectionsView(
                    searchText: searchText,
                    sectionHeader: { sectionHeader(prefixes: "App Info", title: $0) }
                )
                DeviceInfoSectionsView(
                    searchText: searchText,
                    sectionHeader: { sectionHeader(prefixes: "Device Info", title: $0) }
                )
            }
        }
        .navigationTitle("Settings")
        // NOTE:
        // Use `formCellCopyable` here (as a wrapper of entire `SherlockForm`) to allow ALL `xxxCell`s to be copyable.
        // To Make each cell copyable one by one instead, call it as a wrapper of each form cell.
        .formCellCopyable(true)
        // For aligning icons and texts horizontally.
        .formCellIconWidth(30)
    }

    /// Customized form cell using `vstackCell`.
    @ViewBuilder
    private var customVStackCell: some View
    {
        vstackCell(
            keywords: "Add", "your", "favorite", "keywords", "as much as possible", "Hello", "SherlockForms",
            copyableKeyValue: .init(key: "Hello SherlockForms!"),
            alignment: .center,
            content: {
                Text("🕵️‍♂️").font(.system(size: 48))
                Text("Hello SherlockForms!").font(.title)
            }
        )
            // NOTE:
            // `formCellContentModifier` allows to modify `cellContent` that wraps `vstackCell`'s `content`).
            //
            // This method may sometimes be needed for SwiftUI View method-chaining
            // to NOT start from "receiver" but from its `cellContent`.
            .formCellContentModifier { cellContent in
                cellContent
                    .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: 150)
                    .padding()
                    .onTapGesture {
                        print("Hello SherlockForms!")
                    }
            }
    }
}

// MARK: - Private

private func sectionHeader(prefixes: String..., title: String) -> String
{
    (prefixes + [title]).filter { !$0.isEmpty }.joined(separator: " > ")
}

@MainActor
private func setAnimationSpeed(isSlowAnimation: Bool)
{
    if isSlowAnimation {
        Helper.setAnimationSpeed(0.1)
    }
    else {
        Helper.setAnimationSpeed(1)
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        RootView()
    }
}

