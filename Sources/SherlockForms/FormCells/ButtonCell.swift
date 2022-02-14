import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func buttonCell(
        icon: Image? = nil,
        title: String,
        action: @escaping () -> Void
    ) -> ButtonCell
    {
        ButtonCell(
            icon: icon,
            title: title,
            action: action,
            canShowCell: canShowCell
        )
    }
}

// MARK: - ButtonCell

@MainActor
public struct ButtonCell: View
{
    private let icon: Image?
    private let title: String
    private let action: () -> Void
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        action: @escaping () -> Void,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.action = action
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        HStackCell(
            keywords: [title],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title) : nil
        ) {
            icon
            Button(title, action: {
                Task {
                    action()
                }
            })
        }
    }
}
