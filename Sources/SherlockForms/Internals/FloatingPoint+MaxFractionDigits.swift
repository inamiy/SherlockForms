import Foundation

extension BinaryFloatingPoint
{
    func string(maxFractionDigits: Int? = nil) -> String
    {
        guard let maxFractionDigits = maxFractionDigits else {
            return String(Double(self))
        }

        let number = NSNumber(value: Double(self))
        numberFormatter.minimumFractionDigits = maxFractionDigits
        numberFormatter.maximumFractionDigits = maxFractionDigits
        return numberFormatter.string(from: number)!
    }
}

private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()
