import SwiftUI

extension View
{
    @MainActor
    func hud<Content: View>(
        presentation: Binding<HUDPresentation?>,
        alignment: HUDAlignment,
        @ViewBuilder content: @escaping (HUDPresentation) -> Content
    ) -> some View
    {
        ZStack(alignment: alignment.kind.zstackAlignment) {
            self

            if let presentation_ = presentation.wrappedValue {
                let duration = presentation_.duration

                HUD(content: { content(presentation_) })
                    .transition(alignment.kind.preferredTransition)
                    .onAppear {
                        Task {
                            // Keep presenting for `duration`.
                            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

                            // Then, hide if still in the same presentation.
                            if presentation_ == presentation.wrappedValue {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    presentation.wrappedValue = nil
                                }
                            }
                        }
                    }
                    .zIndex(1)
            }
        }
    }
}

// MARK: - HUD

// Originally from https://www.fivestars.blog/articles/swiftui-hud/
@MainActor
struct HUD<Content: View>: View
{
    @ViewBuilder let content: () -> Content

    var body: some View
    {
        content()
            .padding(.horizontal, 12)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(Color.white)
                    .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
            )
            .padding(16)
    }
}
