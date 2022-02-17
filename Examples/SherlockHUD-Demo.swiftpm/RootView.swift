import SwiftUI
import SherlockHUD

@MainActor
struct RootView: View
{
    /// - Note:
    /// Attaching `.enableSherlockHUD(true)` to topmost view will allow using `showHUD`.
    /// See `SherlockHUD` module for more information.
    @Environment(\.showHUD)
    private var showHUD: @MainActor (HUDMessage) -> Void

    var body: some View
    {
        VStack(spacing: 16) {
            Button("Top") {
                showHUD(randomHUDMessage(alignment: .top))
            }
            Button("Center") {
                showHUD(randomHUDMessage(alignment: .center))
            }
            Button("Bottom") {
                showHUD(randomHUDMessage(alignment: .bottom))
            }
            Button("Dismiss All") {
                showHUD(.dismiss(alignment: .top))
                showHUD(.dismiss(alignment: .center))
                showHUD(.dismiss(alignment: .bottom))
            }
        }
        .font(.largeTitle)
    }

    func randomHUDMessage(alignment: HUDAlignment) -> HUDMessage
    {
        let duration: TimeInterval = .random(in: 1 ... 3)

        let content: AnyView? = {
            switch (0 ... 2).randomElement()! {
            case 0: return AnyView(Text("Complete!"))
            case 1: return AnyView(Text(Constant.loremIpsum))
            case 2: return nil // Use `.loading`
            default: fatalError()
            }
        }()

        if let content = content {
            return .init(duration: duration, alignment: alignment, content: {
                content
            })
        }
        else {
            return .loading(message: "Loading", duration: duration, alignment: alignment)
        }
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        RootView()
    }
}

