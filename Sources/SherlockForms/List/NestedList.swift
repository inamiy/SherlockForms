import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    /// Creates a hierarchical list that identifies its rows based on a key path to the identifier of the underlying data.
    ///
    /// - See: https://developer.apple.com/documentation/swiftui/list/init(_:id:children:rowcontent:)-93wbq
    @ViewBuilder
    public func nestedList<Data, ID, RowContent>(
        data: Data,
        id: KeyPath<Data.Element, ID>,
        rowContent: @escaping (Data.Element) -> RowContent
    ) -> some View
    where
        Data: MutableCollection & RangeReplaceableCollection,
        Data.Element: NestedListItem,
        ID: Hashable,
        RowContent: View
    {
        NestedList(
            data: data,
            id: id,
            canShowCell: canShowCell,
            rowContent: rowContent
        )
    }

    /// Creates a hierarchical list.
    @ViewBuilder
    public func nestedList<Data, RowContent>(
        data: Data,
        rowContent: @escaping (Data.Element) -> RowContent
    ) -> some View
    where
        Data: MutableCollection & RangeReplaceableCollection,
        Data.Element: NestedListItem & Identifiable,
        RowContent: View
    {
        nestedList(
            data: data,
            id: \.id,
            rowContent: rowContent
        )
    }
}

// MARK: - NestedList

@MainActor
private struct NestedList<Data, ID, RowContent>: View
where
    Data: MutableCollection & RangeReplaceableCollection,
    Data.Element: NestedListItem,
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
            data.compactMap { $0.filter(canShowCell: canShowCell) },
            id: id,
            children: \.children,
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

// MARK: - NestedListItem

/// Recursive protocol that represents displaying nested list items in ``SherlockView/nestedList(data:id:rowContent:)``.
public protocol NestedListItem
{
    associatedtype Content

    /// Content body of the item.
    var content: Content { get }

    var children: [Self]? { get }

    init(content: Content, children: [Self]?)

    /// Search keywords derived from ``content``.
    func getKeywords() -> [String]

    /// Copyable key-value pair derived from ``content``.
    func getFormCellCopyableKeyValue() -> FormCellCopyableKeyValue?
}

extension NestedListItem where Content: CustomStringConvertible
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

extension NestedListItem
{
    /// Recursive filtering.
    /// Rule: If child item matches, then parent item should also be visible.
    @MainActor
    fileprivate func filter(
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool
    ) -> Self?
    {
        if canShowCell(getKeywords()) {
            return self
        }

        if let children = children, !children.isEmpty {
            let filteredChildren = children.compactMap { $0.filter(canShowCell: canShowCell) }

            if !filteredChildren.isEmpty {
                return Self.init(content: content, children: filteredChildren)
            }
        }

        return nil
    }
}
