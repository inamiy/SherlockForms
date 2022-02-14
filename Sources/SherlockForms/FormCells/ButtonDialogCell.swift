import SwiftUI

// MARK: - Constructors

@available(iOS 15.0, *)
extension SherlockView
{
    /// `buttonCell` with `confirmationDialog`.
    @ViewBuilder
    public func buttonDialogCell<Buttons>(
        icon: Image? = nil,
        title: String,
        dialogTitle: String? = nil,
        @ViewBuilder dialogButtons: @escaping (_ completion: @escaping () -> Void) -> Buttons
    ) -> ButtonDialogCell
        where Buttons: View
    {
        ButtonDialogCell(
            icon: icon,
            title: title,
            dialogTitle: dialogTitle,
            dialogButtons: dialogButtons,
            canShowCell: canShowCell
        )
    }
}

// MARK: - ButtonDialogCell

@MainActor
@available(iOS 15.0, *)
public struct ButtonDialogCell: View
{
    private let icon: Image?
    private let title: String
    private let dialogTitle: String?
    private let dialogButtons: (_ completion: @escaping () -> Void) -> AnyView
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    @Environment(\.formCellContentModifier)
    private var formCellContentModifier: AnyViewModifier

    @State private var confirmation: Void?

    internal init<Buttons>(
        icon: Image? = nil,
        title: String,
        dialogTitle: String? = nil,
        dialogButtons: @escaping (_ completion: @escaping () -> Void) -> Buttons,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
        where Buttons: View
    {
        self.icon = icon
        self.title = title
        self.dialogTitle = dialogTitle
        self.dialogButtons = { AnyView(dialogButtons($0)) }
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        let hasDialogTitle = !(dialogTitle ?? "").isEmpty

        ButtonCell(
            icon: icon,
            title: title,
            action: {
                confirmation = ()
            },
            canShowCell: canShowCell
        )
            .formCellContentModifier {
                $0.confirmationDialog(
                    title: { _ in Text(dialogTitle ?? title) },
                    titleVisibility: hasDialogTitle ? .visible : .automatic,
                    unwrapping: $confirmation,
                    actions: { _ in
                        dialogButtons {
                            confirmation = nil
                        }
                    },
                    message: { _ in }
                )
            }
    }
}
