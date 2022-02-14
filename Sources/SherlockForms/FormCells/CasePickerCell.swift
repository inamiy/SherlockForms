import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    /// Picker cell from `enum Value`.
    @ViewBuilder
    public func casePickerCell<Value>(
        icon: Image? = nil,
        title: String,
        selection: Binding<Value>
    ) -> some View
        where Value: CaseIterable & Hashable
    {
        CasePickerCell(icon: icon, title: title, selection: selection, canShowCell: canShowCell)
    }

    /// Picker cell from `enum Value` that is `RawRepresentable`.
    @ViewBuilder
    public func casePickerCell<Value>(
        icon: Image? = nil,
        title: String,
        selection: Binding<Value>
    ) -> some View
        where Value: CaseIterable & Hashable & RawRepresentable
    {
        RawRepresentableCasePickerCell(icon: icon, title: title, selection: selection, canShowCell: canShowCell)
    }
}

// MARK: - CasePickerCell

public struct CasePickerCell<Value>: View
    where Value: Hashable & CaseIterable
{
    private let icon: Image?
    private let title: String
    private let selection: Binding<Value>
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        selection: Binding<Value>,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.selection = selection
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        HStackCell(
            keywords: [title, "\(selection.wrappedValue)"],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: "\(selection.wrappedValue)") : nil
        ) {
            Picker(selection: selection, label: Text(title)) {
                ForEach(Array(Value.allCases), id: \.self) { value in
                    Text("\(String(describing: value))")
                }
            }
        }
    }
}

// MARK: - RawRepresentableCasePickerCell

@MainActor
public struct RawRepresentableCasePickerCell<Value>: View
    where Value: Hashable & CaseIterable & RawRepresentable
{
    private let icon: Image?
    private let title: String
    private let selection: Binding<Value>
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        selection: Binding<Value>,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.selection = selection
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        let rawValue = selection.wrappedValue.rawValue

        HStackCell(
            keywords: [title, "\(rawValue)"],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: "\(rawValue)") : nil
        ) {
            Picker(selection: selection, label: Text(title)) {
                ForEach(Array(Value.allCases), id: \.self) { value in
                    Text("\(String(describing: value.rawValue))")
                }
            }
        }
    }
}
