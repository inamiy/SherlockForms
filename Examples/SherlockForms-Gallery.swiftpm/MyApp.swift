import SwiftUI
import SherlockDebugForms

private let isDebug = false

@main
struct MyApp: App
{
    var body: some Scene
    {
        WindowGroup {
            NavigationView {
                if isDebug {
                    // DEBUG: Shortcut presentation.
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
                else {
                    RootView()
                }
            }
            .onAppear {
                guard isDebug else { return }

                // DEBUG: Insert intial UserDefaults values.
                UserDefaults.standard.set(
                    "John Appleseed",
                    forKey: UserDefaultsStringKey.username.rawValue
                )

                UserDefaults.standard.set(
                    "john@example.com",
                    forKey: UserDefaultsStringKey.email.rawValue
                )

                UserDefaults.standard.set(
                    "admin",
                    forKey: UserDefaultsStringKey.password.rawValue
                )

                UserDefaults.standard.set(
                    Constant.languages[0],
                    forKey: UserDefaultsStringKey.languageSelection.rawValue
                )

                // Index of `Constant.languages`.
                UserDefaults.standard.set(
                    0,
                    forKey: UserDefaultsIntKey.languageIntSelection.rawValue
                )

                UserDefaults.standard.set(
                    Constant.Status.away.rawValue,
                    forKey: UserDefaultsStringKey.status.rawValue
                )

                UserDefaults.standard.set(
                    true,
                    forKey: UserDefaultsBoolKey.lowPowerMode.rawValue
                )

                UserDefaults.standard.set(
                    1.0,
                    forKey: UserDefaultsDoubleKey.speed.rawValue
                )

                UserDefaults.standard.set(
                    12.0,
                    forKey: UserDefaultsDoubleKey.fontSize.rawValue
                )

                UserDefaults.standard.set(
                    Date().addingTimeInterval(-86400 * 365 * 20),
                    forKey: UserDefaultsDateKey.birthday.rawValue
                )

                UserDefaults.standard.set(
                    Date(),
                    forKey: UserDefaultsDateKey.alarm.rawValue
                )

                // For testing long string in UserDefaults.
                UserDefaults.standard.set(
                    Array(repeating: Constant.loremIpsum, count: 10).joined(separator: "\n"),
                    forKey: UserDefaultsStringKey.testLongUserDefaults.rawValue
                )
            }
            .enableSherlockHUD(true)
        }
    }
}
