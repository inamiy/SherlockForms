import SwiftUI

/// `HUDPresentation` with `alignment`, used for `@Environment(\.showHUD)`.
public struct HUDMessage: Hashable, Sendable
{
    /// - Note: `nil` as dismissal.
    let presentation: HUDPresentation?

    let alignment: HUDAlignment

    private init(
        presentation: HUDPresentation?,
        alignment: HUDAlignment
    )
    {
        self.presentation = presentation
        self.alignment = alignment
    }

    /// Initializer with `@ViewBuilder`.
    public init<Content>(
        duration: TimeInterval = 2,
        alignment: HUDAlignment = .bottom,
        @ViewBuilder content: () -> Content
    )
        where Content: View
    {
        self.init(
            presentation: .init(content: AnyView(content()), duration: duration),
            alignment: alignment
        )
    }

    /// Message string initializer.
    public init(
        message: String,
        duration: TimeInterval = 2,
        alignment: HUDAlignment = .bottom
    )
    {
        self.init(
            duration: duration,
            alignment: alignment,
            content: { Text(message) }
        )
    }

    /// Loading initializer.
    public static func loading(
        message: String,
        duration: TimeInterval = 2,
        alignment: HUDAlignment = .bottom
    ) -> HUDMessage
    {
        self.init(
            duration: duration,
            alignment: alignment,
            content: { ProgressView(message) }
        )
    }

    /// Dismissal initializer.
    public static func dismiss(alignment: HUDAlignment) -> HUDMessage
    {
        self.init(presentation: nil, alignment: alignment)
    }
}
