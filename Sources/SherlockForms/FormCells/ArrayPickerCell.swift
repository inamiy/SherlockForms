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
    {
        ArrayPickerCell(icon: icon, title: title, selection: selection, values: values, canShowCell: canShowCell)
    }

    /// Async-picker cell with `selection: Binding<Int>` from `action`-fetched values.
    ///
    /// 1. Before `action`: Shows `title` and `accessory`
    /// 2. After `action`: Shows ``ArrayPickerCell`` with values being fetched by `action`.
    ///
    /// # Known issue
    /// When this cell appears at middle of the form after scroll, and `accessory` contains `ProgressView`,
    /// it may not animate correctly, possibly due to SwiftUI bug.
    @ViewBuilder
    public func arrayPickerCell<Value, Accessory>(
        icon: Image? = nil,
        title: String,
        selection: Binding<Int>,
        @ViewBuilder accessory: @escaping () -> Accessory,
        action: @Sendable @escaping () async throws -> [Value],
        valueType: Value.Type = Value.self
    ) -> some View
        where Accessory: View
    {
        AsyncArrayPickerCell(
            icon: icon,
            title: title,
            selection: selection,
            accessory: accessory,
            action: action,
            canShowCell: canShowCell
        )
    }
}

// MARK: - ArrayPickerCell

@MainActor
public struct ArrayPickerCell<Value>: View
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
            ZStack(alignment: .trailing) {
                Group {
                    icon

                    Picker(selection: selection) {
                        ForEach(0 ..< values.count) { i in
                            Text("\(String(describing: values[i]))")
                        }
                    } label: {
                        Text(title)
                    }
                }

                ProgressView()
                    .padding(.trailing, 16)
                    .opacity(values.isEmpty ? 1 : 0)
            }
        }
    }
}

// MARK: - AsyncArrayPickerCell

@MainActor
public struct AsyncArrayPickerCell<Value, Accessory>: View
    where Accessory: View
{
    private let icon: Image?
    private let title: String
    private let selection: Binding<Int>
    private let accessory: () -> AnyView
    private let action: () async throws -> [Value]
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @State private var values: [Value] = []

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        selection: Binding<Int>,
        @ViewBuilder accessory: @escaping () -> Accessory,
        action: @Sendable @escaping () async throws -> [Value],
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.selection = selection
        self.accessory = { AnyView(accessory()) }
        self.action = action
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        if values.isEmpty {
            TextCell(icon: icon, title: title, value: nil, accessory: accessory, canShowCell: canShowCell)
                .onAppear {
                    guard values.isEmpty else { return }

                    Task {
                        values = try await action()
                    }
                }
        }
        else {
            ArrayPickerCell(icon: icon, title: title, selection: selection, values: values, canShowCell: canShowCell)
        }
    }
}
