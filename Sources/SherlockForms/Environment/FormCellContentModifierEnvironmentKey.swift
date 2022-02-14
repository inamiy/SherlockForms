import SwiftUI

extension View
{
    @MainActor
    public func formCellContentModifier<VM>(_ modifier: VM) -> some View
        where VM: ViewModifier
    {
        environment(\.formCellContentModifier, AnyViewModifier(modifier))
    }

    @MainActor
    public func formCellContentModifier<Content>(
        _ modify: @escaping (AnyViewModifier.Content) -> Content
    ) -> some View
        where Content: View
    {
        environment(\.formCellContentModifier, AnyViewModifier(modify))
    }
}

// MARK: - FormCellContentModifierEnvironmentKey

private struct FormCellContentModifierEnvironmentKey: EnvironmentKey
{
    static let defaultValue: AnyViewModifier = .init()
}

extension EnvironmentValues
{
    var formCellContentModifier: AnyViewModifier
    {
        get { self[FormCellContentModifierEnvironmentKey.self] }
        set { self[FormCellContentModifierEnvironmentKey.self] = newValue }
    }
}
