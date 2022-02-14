import SwiftUI

extension View
{
    @MainActor
    func hideKeyboard()
    {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
