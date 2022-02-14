import SwiftUI

extension View
{
    /// - Note: Developer should call this method at the topmost view.
    @MainActor
    @ViewBuilder
    public func enableSherlockHUD(_ isEnabled: Bool) -> some View
    {
        if isEnabled {
            self.modifier(EnableHUDViewModifier())
        }
        else {
            self
        }
    }
}

// MARK: - Internals

/// Top / center / bottom HUD-presentation state storage & dispatcher.
@MainActor
struct EnableHUDViewModifier: ViewModifier
{
    @State private var topHUDPresentation: HUDPresentation?
    @State private var centerHUDPresentation: HUDPresentation?
    @State private var bottomHUDPresentation: HUDPresentation?

    func body(content: Content) -> some View
    {
        content
            // Pass `showHUD` handler to child views.
            .environment(\.showHUD, { message in
                switch message.alignment.kind {
                case .top:
                    showHUDAnimation(
                        presentation: message.presentation,
                        binding: $topHUDPresentation
                    )
                case .center:
                    showHUDAnimation(
                        presentation: message.presentation,
                        binding: $centerHUDPresentation
                    )
                case .bottom:
                    showHUDAnimation(
                        presentation: message.presentation,
                        binding: $bottomHUDPresentation
                    )
                }
            })
            // Observe presentation changes for top / center / bottom HUD each.
            .hud(presentation: $topHUDPresentation, alignment: .top) { message in
                message.content
            }
            .hud(presentation: $centerHUDPresentation, alignment: .center) { message in
                message.content
            }
            .hud(presentation: $bottomHUDPresentation, alignment: .bottom) { message in
                message.content
            }
    }

    private func showHUDAnimation(
        presentation: HUDPresentation?,
        binding: Binding<HUDPresentation?>
    )
    {
        if let presentation = presentation {
            // Remove previous HUD immediately (no animation).
            binding.wrappedValue = nil

            // Show HUD after tick.
            Task {
                try await Task.sleep(nanoseconds: 1_000_000)

                withAnimation(.easeInOut(duration: 0.25)) {
                    binding.wrappedValue = presentation
                }
            }
        }
        else {
            withAnimation(.easeInOut(duration: 0.25)) {
                binding.wrappedValue = nil
            }
        }
    }
}
