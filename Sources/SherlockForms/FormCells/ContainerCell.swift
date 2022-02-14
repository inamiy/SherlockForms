import SwiftUI

// MARK: - ContainerCell

/// Form cell container that holds `keywords` and `canShowCell` to get filtered by ``SherlockForm``
/// and also allows ContextMenu "Copy" when `copyableKeyValue` is set.
@MainActor
public struct ContainerCell<Container: View, Content: View>: View
{
    private let keywords: [String]
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool
    private let copyableKeyValue: FormCellCopyableKeyValue?
    private let containerInit: (() -> Content) -> Container
    private let content: () -> Content

    @Environment(\.formCellContentModifier)
    private var formCellContentModifier: AnyViewModifier

    internal init(
        keywords: [String],
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true },
        copyableKeyValue: FormCellCopyableKeyValue?,
        containerInit: @escaping (() -> Content) -> Container,
        @ViewBuilder content: @escaping () -> Content
    )
    {
        self.keywords = keywords
        self.canShowCell = canShowCell
        self.copyableKeyValue = copyableKeyValue
        self.containerInit = containerInit
        self.content = content
    }

    /// Creates ``HStackCell``.
    internal init(
        keywords: [String],
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true },
        copyableKeyValue: FormCellCopyableKeyValue?,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    )
        where Container == HStack<Content>
    {
        self.keywords = keywords
        self.canShowCell = canShowCell
        self.copyableKeyValue = copyableKeyValue
        self.containerInit = { HStack(alignment: alignment, content: $0) }
        self.content = content
    }

    /// Creates ``VStackCell``.
    internal init(
        keywords: [String],
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true },
        copyableKeyValue: FormCellCopyableKeyValue?,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping () -> Content
    )
        where Container == VStack<Content>
    {
        self.keywords = keywords
        self.canShowCell = canShowCell
        self.copyableKeyValue = copyableKeyValue
        self.containerInit = { VStack(alignment: alignment, content: $0) }
        self.content = content
    }

    public var body: some View
    {
        if canShowCell(keywords) {
            _body
        }
    }

    @ViewBuilder
    private var _body: some View
    {
        if let copyableKeyValue = copyableKeyValue {
            containerInit { content() }
            .modifier(formCellContentModifier)
            .modifier(CopyableViewModifier(key: copyableKeyValue.key, value: copyableKeyValue.value))
        }
        else {
            containerInit { content() }
            .modifier(formCellContentModifier)
        }
    }
}
