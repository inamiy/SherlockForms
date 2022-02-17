import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func textEditorCell<Content>(
        icon: Image? = nil,
        title: String,
        value: Binding<String>,
        placeholder: String = "Input Value",
        modify: @escaping (_ textEditor: AnyView) -> Content
    ) -> TextEditorCell<Content>
        where Content: View
    {
        TextEditorCell(
            icon: icon,
            title: title,
            value: value,
            placeholder: placeholder,
            modify: modify,
            canShowCell: canShowCell
        )
    }
}

// MARK: - TextEditorCell

@MainActor
public struct TextEditorCell<Content: View>: View
{
    private let icon: Image?
    private let title: String
    private let value: Binding<String>
    private let placeholder: String
    private let modify: (_ textEditor: AnyView) -> Content
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        value: Binding<String>,
        placeholder: String,
        modify: @escaping (_ textEditor: AnyView) -> Content,
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
                modify(AnyView(TextEditorWithPlaceholder(placeholder, text: value)))
            }
        }
    }
}
