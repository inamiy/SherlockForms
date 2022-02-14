import SwiftUI

public struct AnyViewModifier: ViewModifier
{
    private let _body: (Content) -> AnyView

    public init<VM: ViewModifier>(_ modifier: VM)
    {
        self._body = { AnyView($0.modifier(modifier)) }
    }

    public init<Content2>(_ modify: @escaping (Content) -> Content2)
        where Content2: View
    {
        self._body = { AnyView(modify($0)) }
    }

    public init()
    {
        self._body = { AnyView($0) }
    }

    public func body(content: Content) -> some View
    {
        _body(content)
    }
}
