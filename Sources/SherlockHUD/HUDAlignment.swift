import SwiftUI

/// Position of HUD presentation.
public struct HUDAlignment: Hashable, Sendable
{
    let kind: Kind

    public static let top: HUDAlignment = .init(kind: .top)
    public static let bottom: HUDAlignment = .init(kind: .bottom)
    public static let center: HUDAlignment = .init(kind: .center)
}

// MARK: - Internals

extension HUDAlignment
{
    enum Kind: Hashable, Sendable
    {
        case top
        case center
        case bottom

        var zstackAlignment: Alignment
        {
            switch self {
            case .top:
                return .top
            case .center:
                return .center
            case .bottom:
                return .bottom
            }
        }

        var preferredTransition: AnyTransition
        {
            switch self {
            case .top:
                return AnyTransition.move(edge: .top).combined(with: .opacity)
            case .bottom:
                return AnyTransition.move(edge: .bottom).combined(with: .opacity)
            case .center:
                return AnyTransition.scale(scale: 0.5).combined(with: .opacity)
            }
        }
    }
}
