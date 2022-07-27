import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    /// Creates a simple list that identifies its rows based on a key path to the identifier of the underlying data.
    @ViewBuilder
    public func simpleList<Data, ID, RowContent>(
        data: Data,
        id: KeyPath<Data.Element, ID>,
        rowContent: @escaping (Data.Element) -> RowContent
    ) -> some View
    where
        Data: MutableCollection & RangeReplaceableCollection,
        Data.Element: SimpleListItem,
        ID: Hashable,
        RowContent: View
    {
        SimpleList(
            data: data,
            id: id,
            canShowCell: canShowCell,
            rowContent: rowContent
        )
    }

    /// Creates a simple list.
    @ViewBuilder
    public func simpleList<Data, RowContent>(
        data: Data,
        rowContent: @escaping (Data.Element) -> RowContent
    ) -> some View
    where
        Data: MutableCollection & RangeReplaceableCollection,
        Data.Element: SimpleListItem & Identifiable,
        Data.Element.ID: Hashable,
        RowContent: View
    {
        simpleList(
            data: data,
            id: \.id,
            rowContent: rowContent
        )
    }
}

// MARK: - SimpleList

@MainActor
private struct SimpleList<Data, ID, RowContent>: View
where
    Data: MutableCollection & RangeReplaceableCollection,
    Data.Element: SimpleListItem,
    ID: Hashable,
    RowContent: View
{
    private let data: Data
    private let id: KeyPath<Data.Element, ID>

    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    private let rowContent: (Data.Element) -> RowContent

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        data: Data,
        id: KeyPath<Data.Element, ID>,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool,
        rowContent: @escaping (Data.Element) -> RowContent
    )
    {
        self.data = data
        self.id = id
        self.canShowCell = canShowCell
        self.rowContent = rowContent
    }

    public var body: some View
    {
        List(
            data.filter { canShowCell($0.getKeywords()) },
            id: id,
            rowContent: { item in
                if isCopyable, let copyableKeyValue = item.getFormCellCopyableKeyValue() {
                    rowContent(item)
                        .modifier(CopyableViewModifier(key: copyableKeyValue.key, value: copyableKeyValue.value))
                }
                else {
                    rowContent(item)
                }
            }
        )
    }
}

// MARK: - SimpleListItem

/// Recursive protocol that represents displaying nested list items in ``SherlockView/list(data:id:rowContent:)``.
public protocol SimpleListItem
{
    associatedtype Content

    /// Content body of the item.
    var content: Content { get }

    /// Search keywords derived from ``content``.
    func getKeywords() -> [String]

    /// Copyable key-value pair derived from ``content``.
    func getFormCellCopyableKeyValue() -> FormCellCopyableKeyValue?
}

extension SimpleListItem where Content: CustomStringConvertible
{
    // Default implementation.
    public func getKeywords() -> [String]
    {
        [content.description]
    }

    public func getFormCellCopyableKeyValue() -> FormCellCopyableKeyValue?
    {
        .init(key: content.description)
    }
}
