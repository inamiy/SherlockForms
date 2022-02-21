import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func textCell(
        icon: Image? = nil,
        title: String,
        value: Any? = nil
    ) -> TextCell<EmptyView>
    {
        TextCell(
            icon: icon,
            title: title,
            value: value,
            accessory: {},
            canShowCell: canShowCell
        )
    }

    @ViewBuilder
    public func textCell<Accessory>(
        icon: Image? = nil,
        title: String,
        value: Any? = nil,
        @ViewBuilder accessory: @escaping () -> Accessory
    ) -> TextCell<Accessory>
        where Accessory: View
    {
        TextCell(
            icon: icon,
            title: title,
            value: value,
            accessory: accessory,
            canShowCell: canShowCell
        )
    }
}

// MARK: - TextCell

@MainActor
public struct TextCell<Accessory>: View
    where Accessory: View
{
    private let icon: Image?
    private let title: String
    private let value: String?
    private let accessory: () -> AnyView?
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        value: Any?,
        @ViewBuilder accessory: @escaping () -> Accessory,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.value = value.map { "\($0)" }
        self.accessory = { AnyView(accessory()) }
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
            if let accessory = accessory() {
                accessory
            }
        }
    }
}
