import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    /// Picker cell with `selection: Binding<Int>` from `values` array.
    @ViewBuilder
    public func arrayPickerCell<Value>(
        icon: Image? = nil,
        title: String,
        selection: Binding<Int>,
        values: [Value]
    ) -> some View
        where Value: Hashable
    {
        ArrayPickerCell(icon: icon, title: title, selection: selection, values: values, canShowCell: canShowCell)
    }
}

// MARK: - ArrayPickerCell

@MainActor
public struct ArrayPickerCell<Value>: View
    where Value: Hashable
{
    private let icon: Image?
    private let title: String
    private let selection: Binding<Int>
    private let values: [Value]
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        selection: Binding<Int>,
        values: [Value],
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.selection = selection
        self.values = values
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        HStackCell(
            keywords: [title],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable
                ? .init(
                    key: title,
                    value: values[safe: selection.wrappedValue].map { "\($0)" }
                )
                : nil
        ) {
            icon
            Picker(selection: selection, label: Text(title)) {
                ForEach(0 ..< values.count) { i in
                    Text("\(String(describing: values[i]))")
                }
            }
        }
    }
}
