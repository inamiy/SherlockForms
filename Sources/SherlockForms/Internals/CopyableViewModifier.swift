import SwiftUI

/// `ViewModifier` for showing "Copy (key & value)" context-menu.
struct CopyableViewModifier: ViewModifier
{
    private let key: String
    private let value: String?

    @Environment(\.showHUD)
    private var showHUD: (HUDMessage) -> Void

    init(key: String, value: String? = nil)
    {
        self.key = key
        self.value = value
    }

    func body(content: Content) -> some View
    {
        content.contextMenu {
            if let value = value {
                Button { copyString(key) } label: {
                    Label("Copy Key", systemImage: "doc.on.doc")
                }

                Button { copyString(value) } label: {
                    Label("Copy Value", systemImage: "doc.on.doc")
                }
            }
            else {
                Button { copyString(key) } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        }
    }

    private func copyString(_ string: String)
    {
        UIPasteboard.general.string = string
        
        showHUD(
            .init(
                message: "Copied \"\(string.truncated(maxCount: 50))\"",
                duration: 2,
                alignment: .bottom
            )
        )
    }
}
