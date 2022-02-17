import SwiftUI

@MainActor
func hideKeyboard()
{
    let resign = #selector(UIResponder.resignFirstResponder)
    UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
}

extension UIView
{
    // NOTE:
    // `UIView.touchesEnded` extension works better than `form.onTapGesture`
    // which causes some form UI to stop working.
    // cf. https://developer.apple.com/forums/thread/127196
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)

        let className = "\(self)"
        if className.contains("CellHostingView") && className.contains("SwiftUI") {
            hideKeyboard()
        }
    }
}
