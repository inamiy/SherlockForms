import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func toggleCell(
        icon: Image? = nil,
        title: String,
        isOn: Binding<Bool>
    ) -> ToggleCell
    {
        ToggleCell(
            icon: icon,
            title: title,
            isOn: isOn,
            canShowCell: canShowCell
        )
    }
}

// MARK: - ToggleCell

@MainActor
public struct ToggleCell: View
{
    private let icon: Image?
    private let title: String
    private let isOn: Binding<Bool>
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        isOn: Binding<Bool>,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.isOn = isOn
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        HStackCell(
            keywords: [title],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: "\(isOn.wrappedValue)") : nil
        ) {
            icon
            Text(title)
            Spacer()
            Toggle(isOn: isOn) {
                EmptyView()
            }
            .onTapGesture { /* Don't let wrapper view to steal this tap */ }
        }
    }
}
