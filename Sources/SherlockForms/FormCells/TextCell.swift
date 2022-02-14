import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func textCell(
        icon: Image? = nil,
        title: String,
        value: Any? = nil
    ) -> TextCell
    {
        TextCell(
            icon: icon,
            title: title,
            value: value,
            canShowCell: canShowCell
        )
    }
}

// MARK: - TextCell

@MainActor
public struct TextCell: View
{
    private let icon: Image?
    private let title: String
    private let value: String?
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        value: Any?,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.value = value.map { "\($0)" }
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        HStackCell(
            keywords: [title, value].compactMap { $0 },
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: value) : nil
        ) {
            icon
            Text(title)
            Spacer()
            if let value = value {
                Text(value)
            }
        }
    }
}
