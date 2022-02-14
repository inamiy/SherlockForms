import SwiftUI

extension View
{
    @MainActor
    public func formCellCopyable(_ isCopyable: Bool) -> some View
    {
        environment(\.formCellCopyable, isCopyable)
    }
}

// MARK: - FormCellCopyableEnvironmentKey

private struct FormCellCopyableEnvironmentKey: EnvironmentKey
{
    static let defaultValue: Bool = false
}

extension EnvironmentValues
{
    var formCellCopyable: Bool
    {
        get { self[FormCellCopyableEnvironmentKey.self] }
        set { self[FormCellCopyableEnvironmentKey.self] = newValue }
    }
}
