import SwiftUI

extension View
{
    @MainActor
    public func formCellIconWidth(_ iconWidth: CGFloat?) -> some View
    {
        environment(\.formCellIconWidth, iconWidth)
    }
}

// MARK: - FormCellIconWidthEnvironmentKey

private struct FormCellIconWidthEnvironmentKey: EnvironmentKey
{
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues
{
    var formCellIconWidth: CGFloat?
    {
        get { self[FormCellIconWidthEnvironmentKey.self] }
        set { self[FormCellIconWidthEnvironmentKey.self] = newValue }
    }
}
