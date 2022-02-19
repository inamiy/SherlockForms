import UIKit

// Trying to find which text field is active ios
// See https://stackoverflow.com/a/40352519/666371.
extension UIView
{
    private enum Static
    {
        weak static var responder: UIView?
    }

    static func currentFirstResponder() -> UIView?
    {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIView._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap()
    {
        Static.responder = self
    }
}

