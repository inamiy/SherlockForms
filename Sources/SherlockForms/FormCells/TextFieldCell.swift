import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func textFieldCell<Content>(
        icon: Image? = nil,
        title: String,
        value: Binding<String>,
        placeholder: String = "Input Value",
        modify: @escaping (TextField<Text>) -> Content
    ) -> TextFieldCell<Content>
        where Content: View
    {
        TextFieldCell(
            icon: icon,
            title: title,
            value: value,
            placeholder: placeholder,
            modify: modify,
            canShowCell: canShowCell
        )
    }
}

// MARK: - TextFieldCell

@MainActor
public struct TextFieldCell<Content: View>: View
{
    private let icon: Image?
    private let title: String
    private let value: Binding<String>
    private let placeholder: String
    private let modify: (TextField<Text>) -> Content
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        value: Binding<String>,
        placeholder: String,
        modify: @escaping (TextField<Text>) -> Content,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.modify = modify
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        HStackCell(
            keywords: [title, value.wrappedValue].compactMap { $0 },
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: value.wrappedValue) : nil
        ) {
            icon
            Text(title)
            Spacer(minLength: 16)
            if let value = value {
                modify(TextField(placeholder, text: value))
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
