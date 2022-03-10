import UIKit

extension Helper
{
    @MainActor
    public static func setAnimationSpeed(_ speed: Float)
    {
        UIApplication.shared.windows.first?.layer.speed = speed
    }
}
