import SwiftUI

/// HUD presentation data structure.
struct HUDPresentation: Hashable, Sendable
{
    let id = UUID()
    let content: AnyView
    let duration: TimeInterval

    static func == (l: HUDPresentation, r: HUDPresentation) -> Bool
    {
        l.id == r.id
    }

    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
