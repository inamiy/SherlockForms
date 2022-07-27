# 🕵️‍♂️ SherlockForms

> What one man can invent Settings UI, another can discover its field.
>
> -- Sherlock Forms

An elegant SwiftUI Form builder to create a searchable Settings and DebugMenu screens for iOS.

(Supports from iOS 14, except `.searchable` works from iOS 15)

## Overview

| Normal | Searching | Context Menu |
|---|---|---|
| <img src="https://user-images.githubusercontent.com/138476/153866269-62c7af4b-48ee-47b7-a66d-7c0ba2e42f07.PNG"  width="300"> | <img src="https://user-images.githubusercontent.com/138476/153866280-ce060b33-b66a-4e5f-85bb-cf709983ba72.PNG"  width="300"> | <img src="https://user-images.githubusercontent.com/138476/153866283-9b2718c3-9e33-43ca-94ee-5e0e3add2d25.PNG"  width="300"> |

| UserDefaults | App Info | Device Info |
|---|---|---|
| <img src="https://user-images.githubusercontent.com/138476/153866292-034a8f3f-7861-4a24-8010-aad52b36da42.PNG"  width="300"> | <img src="https://user-images.githubusercontent.com/138476/153866297-102dd994-69b6-4047-87f9-a2465e7092da.PNG"  width="300"> | <img src="https://user-images.githubusercontent.com/138476/153866301-c354f401-2982-4186-b4b1-0625728a8e8d.PNG"  width="300"> |

This repository consists of 3 modules:

1. `SherlockForms`: SwiftUI Form builder to enhance cell findability using iOS 15 `.searchable`.
    - [x] Various form cells to automagically interact with `.searchable`, including Text, Button, Toggle, Picker, NavigationLink, etc.
    - [x] "Copy text" from context menu by long-press
2. `SherlockDebugForms`: Useful app/device info-views and helper methods, specifically for debugging purpose.
    - [x] App Info view
    - [x] Device Info view
    - [x] UserDefaults Editor
    - [ ] TODO: File Browser
    - [ ] TODO: Console Logger
3. `SherlockHUD`: Standalone, simple-to-use Notification View (Toast) UI used in `SherlockForms`

## Examples

### `SherlockForms` & `SherlockDebugForms`

From [SherlockForms-Gallery app](Examples/SherlockForms-Gallery.swiftpm):

```swift
import SwiftUI
import SherlockDebugForms

/// NOTE: Each view that owns `SherlockForm` needs to conform to `SherlockView` protocol.
@MainActor
struct RootView: View, SherlockView
{
    /// NOTE:
    /// `searchText` is required for `SherlockView` protocol.
    /// This is the only requirement to define as `@State`, and pass it to `SherlockForm`.
    @State public var searchText: String = ""

    @AppStorage("username")
    private var username: String = "John Appleseed"

    @AppStorage("language")
    private var languageSelection: Int = 0

    @AppStorage("status")
    private var status = Constant.Status.online

    ... // Many more @AppStorage properties...

    var body: some View
    {
        // NOTE:
        // `SherlockForm` and `xxxCell` are where all the search magic is happening!
        // Just treat `SherlockForm` as a normal `Form`, and use `Section` and plain SwiftUI views accordingly.
        SherlockForm(searchText: $searchText) {

            // Simple form cells.
            Section {
                textCell(title: "User", value: username)
                arrayPickerCell(title: "Language", selection: $languageSelection, values: Constant.languages)
                casePickerCell(title: "Status", selection: $status)
                toggleCell(title: "Low Power Mode", isOn: $isLowPowerOn)

                sliderCell(
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
                    title: "Font Size",
                    value: $fontSize,
                    in: 8 ... 24,
                    step: 1,
                    maxFractionDigits: 0,
                    valueString: { "\($0) pt" }
                )
            }

            // Navigation Link Cell (`navigationLinkCell`)
            Section {
                navigationLinkCell(
                    title: "UserDefaults",
                    destination: { UserDefaultsListView() }
                )
                navigationLinkCell(
                    title: "App Info",
                    destination: { AppInfoView() }
                )
                navigationLinkCell(
                    title: "Device Info",
                    destination: { DeviceInfoView() }
                )
                navigationLinkCell(title: "Custom Page", destination: {
                    CustomView()
                })
            }

            // Buttons
            Section {
                buttonCell(
                    title: "Reset UserDefaults",
                    action: {
                        Helper.deleteUserDefaults()
                        showHUD(.init(message: "Finished resetting UserDefaults"))
                    }
                )

                buttonDialogCell(
                    title: "Delete All Contents",
                    dialogTitle: nil,
                    dialogButtons: [
                        .init(title: "Delete All Contents", role: .destructive) {
                            try await deleteAllContents()
                            showHUD(.init(message: "Finished deleting all contents"))
                        },
                        .init(title: "Cancel", role: .cancel) {
                            print("Cancelled")
                        }
                    ]
                )
            }
        }
        .navigationTitle("Settings")
        // NOTE:
        // Use `formCopyable` here to allow ALL `xxxCell`s to be copyable.
        .formCopyable(true)
    }
}
```

To get started:

1. Conform your Settings view to `protocol SherlockView`
2. Add `@State var searchText: String` to your view
3. Inside view's `body`, use `SherlockForm` (just like normal `Form`), and use various built-in form components:
    - Basic built-in cells
        - `textCell`
        - `textFieldCell`
        - `textEditorCell`
        - `buttonCell`
        - `buttonDialogCell` (iOS 15)
        - `navigationLinkCell`
        - `toggleCell`
        - `arrayPickerCell`
        - `casePickerCell`
        - `datePickerCell`
        - `sliderCell`
        - `stepperCell`
    - List
        - `simpleList`
        - `nestedList`
    - More customizable cells (part of `ContainerCell`)
        - `hstackCell`
        - `vstackCell`
4. (Optional) Attach `.formCellCopyable(true)` to each cell or entire form.
5. (Optional) Attach `.enableSherlockHUD(true)` to topmost view hierarchy to enable HUD

To customize cell's internal content view rather than cell itself,
use `.formCellContentModifier` which may solve some troubles (e.g. context menu) when customizing cells.

### `SherlockHUD`

```swift
import SwiftUI
import SherlockHUD

@main
struct MyApp: App
{
    var body: some Scene
    {
        WindowGroup {
            NavigationView {
                RootView()
            }
            .enableSherlockHUD(true) // Set at the topmost view!
        }
    }
}

@MainActor
struct RootView: View
{
    /// Attaching `.enableSherlockHUD(true)` to topmost view will allow using `showHUD`.
    @Environment(\.showHUD)
    private var showHUD: (HUDMessage) -> Void

    var body: some View
    {
        VStack(spacing: 16) {
            Button("Tap") {
                showHUD(HUDMessage(message: "Hello SherlockForms!", duration: 2, alignment: .top))
                // alignment = top / center / bottom (default)
                // Can also attach custom view e.g. ProgressView. See also `HUDMessage.loading`.
            }
        }
        .font(.largeTitle)
    }
}
```

See [SherlockHUD-Demo app](Examples/SherlockHUD-Demo.swiftpm) for more information.

## Acknowledgement

- [DebugMenu](https://github.com/noppefoxwolf/DebugMenu) by [@noppefoxwolf](https://github.com/noppefoxwolf) for various useful code in debugging
- [swiftui-navigation](https://github.com/pointfreeco/swiftui-navigation) by [@pointfreeco](https://github.com/pointfreeco) for making smart state-binding techniques in SwiftUI navigation
- [Custom HUDs in SwiftUI | FIVE STARS](https://www.fivestars.blog/articles/swiftui-hud/) by [Federico Zanetello](https://twitter.com/zntfdr) for easy-to-learn SwiftUI HUD development
- [@inamiy](https://github.com/inamiy)'s Wife for dedicated support during this OSS development

## License

[MIT](LICENSE)
