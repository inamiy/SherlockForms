import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    /// Picker cell with `selection: Binding<Value>` from `values` array.
    @ViewBuilder
    public func arrayPickerCell<Value>(
        icon: Image? = nil,
        title: String,
        selection: Binding<Value>,
        values: [Value]
    ) -> some View
        where Value: Hashable
    {
        ArrayPickerCell(icon: icon, title: title, selection: selection, values: values, canShowCell: canShowCell)
    }

    /// Async-picker cell with `selection: Binding<Value>` from `action`-fetched values.
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
        selection: Binding<Value>,
        @ViewBuilder accessory: @escaping () -> Accessory,
        action: @Sendable @escaping () async throws -> [Value],
        valueType: Value.Type = Value.self
    ) -> some View
        where Value: Hashable, Accessory: View
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
    where Value: Hashable
{
    private let icon: Image?
    private let title: String
    private let selection: Binding<Value>
    private let values: [Value]
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    @Environment(\.formCellIconWidth)
    private var iconWidth: CGFloat?

    internal init(
        icon: Image? = nil,
        title: String,
        selection: Binding<Value>,
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
                    value: "\(selection.wrappedValue)"
                )
                : nil
        ) {
            icon.frame(minWidth: iconWidth, maxWidth: iconWidth)

            Picker(selection: selection) {
                ForEach(0 ..< values.count) { i in
                    let value = values[i]
                    Text("\(String(describing: value))")
                        .tag(value)
                }
            } label: {
                Text(title)
            }
            .overlay(
                Group {
                    Spacer()

                    ProgressView()
                        .padding(.trailing, 16)
                        .opacity(values.isEmpty ? 1 : 0)
                }
            )
        }
    }
}

// MARK: - AsyncArrayPickerCell

@MainActor
public struct AsyncArrayPickerCell<Value, Accessory>: View
    where Value: Hashable, Accessory: View
{
    private let icon: Image?
    private let title: String
    private let selection: Binding<Value>
    private let accessory: () -> AnyView
    private let action: () async throws -> [Value]
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @State private var values: [Value] = []

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    @Environment(\.formCellIconWidth)
    private var iconWidth: CGFloat?

    internal init(
        icon: Image? = nil,
        title: String,
        selection: Binding<Value>,
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
