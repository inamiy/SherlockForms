import SwiftUI

// MARK: - Constructors

@available(iOS 15.0, *)
extension SherlockView
{
    /// `buttonCell` with `confirmationDialog`.
    @ViewBuilder
    public func buttonDialogCell(
        icon: Image? = nil,
        title: String,
        dialogTitle: String? = nil,
        dialogButtons: [ButtonDialogCell.DialogButton]
    ) -> ButtonDialogCell
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
    private let dialogButtons: [DialogButton]
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @State private var confirmation: Void?
    @State private var isLoading: Bool = false
    @State private var currentTask: Task<Void, Error>?

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    @Environment(\.formCellIconWidth)
    private var iconWidth: CGFloat?

    internal init(
        icon: Image? = nil,
        title: String,
        dialogTitle: String? = nil,
        dialogButtons: [DialogButton],
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.dialogTitle = dialogTitle
        self.dialogButtons = dialogButtons
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        let hasDialogTitle = !(dialogTitle ?? "").isEmpty

        HStackCell(
            keywords: [title],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title) : nil
        ) {
            Group {
                icon.frame(minWidth: iconWidth, maxWidth: iconWidth)
                Button(title, action: {
                    currentTask?.cancel()
                    isLoading = false
                    confirmation = ()
                })

                if isLoading {
                    Spacer()
                    ProgressView()
                        .onTapGesture {
                            currentTask?.cancel()
                            isLoading = false
                        }
                }
            }
            .confirmationDialog(
                title: { _ in Text(dialogTitle ?? title) },
                titleVisibility: hasDialogTitle ? .visible : .automatic,
                unwrapping: $confirmation,
                actions: { _ in
                    ForEach(0 ..< dialogButtons.count) { i in
                        let dialogButton = dialogButtons[i]
                        let action = dialogButton.action
                        Button.init(dialogButton.title, role: dialogButton.role, action: {
                            currentTask?.cancel()
                            currentTask = Task {
                                confirmation = nil

                                if dialogButton.role == .cancel {
                                    try await action()
                                } else {
                                    isLoading = true
                                    try await action()
                                    isLoading = false
                                }
                            }
                        })
                    }
                },
                message: { _ in }
            )
        }
    }
}

@available(iOS 15.0, *)
extension ButtonDialogCell
{
    public struct DialogButton: Sendable
    {
        let title: String
        let role: ButtonRole?
        let action: @MainActor @Sendable () async throws -> Void

        public init(
            title: String,
            role: ButtonRole? = nil,
            action: @MainActor @Sendable @escaping () async throws -> Void
        )
        {
            self.title = title
            self.role = role
            self.action = action
        }
    }
}
