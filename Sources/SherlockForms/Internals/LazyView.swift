import SwiftUI

/// SwiftUI needs laziness, especially in `NavigationLink`.
public struct LazyView<Content: View>: View
{
    let content: () -> Content

    init(_ content: @autoclosure @escaping () -> Content)
    {
        self.content = content
    }

    public var body: Content
    {
        content()
    }
}
