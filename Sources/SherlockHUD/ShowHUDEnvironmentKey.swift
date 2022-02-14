import SwiftUI

extension EnvironmentValues
{
    public var showHUD: (HUDMessage) -> Void
    {
        get { self[ShowHUDEnvironmentKey.self] }
        set { self[ShowHUDEnvironmentKey.self] = newValue }
    }
}

// MARK: - Private

private struct ShowHUDEnvironmentKey: EnvironmentKey
{
    static let defaultValue: (HUDMessage) -> Void = { _ in }
}

