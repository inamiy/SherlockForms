import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    /// DatePicker cell.
    @ViewBuilder
    public func datePickerCell(
        icon: Image? = nil,
        title: String,
        selection: Binding<Date>,
        in bounds: ClosedRange<Date> = .distantPast ... .distantFuture,
        displayedComponents: DatePickerComponents
    ) -> some View
    {
        DatePickerCell(
            icon: icon,
            title: title,
            selection: selection,
            in: bounds,
            displayedComponents: displayedComponents,
            canShowCell: canShowCell
        )
    }
}

// MARK: - DatePickerCell

public struct DatePickerCell: View
{
    private let icon: Image?
    private let title: String
    private let selection: Binding<Date>
    private let bounds: ClosedRange<Date>
    private let displayedComponents: DatePickerComponents
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        selection: Binding<Date>,
        in bounds: ClosedRange<Date>,
        displayedComponents: DatePickerComponents,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.selection = selection
        self.bounds = bounds
        self.displayedComponents = displayedComponents
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        HStackCell(
            keywords: [title, "\(selection.wrappedValue)"],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: "\(SherlockDate(selection.wrappedValue).rawValue)") : nil
        ) {
            icon
            DatePicker(title, selection: selection, in: bounds, displayedComponents: displayedComponents)
        }
    }
}
