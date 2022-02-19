import SwiftUI

/// `String`-representing `Date` wrapper, useful for storing as `UserDefaults` string via `@AppStorage`.
public struct SherlockDate: RawRepresentable, Comparable
{
    public var date: Date

    public init(_ date: Date = .init())
    {
        self.date = date
    }

    public init?(rawValue: String)
    {
        if let date = Self.formatter.date(from: rawValue) {
            self.date = date
        }
        else {
            return nil
        }
    }

    public var rawValue: String
    {
        Self.formatter.string(from: date)
    }

    public static func == (l: Self, r: Self) -> Bool
    {
        l.date == r.date
    }

    public static func < (l: Self, r: Self) -> Bool
    {
        l.date < r.date
    }

    private static let formatter = ISO8601DateFormatter()
}

// MARK: - Binding

extension Binding where Value == SherlockDate
{
    public var date: Binding<Date>
    {
        .init(
            get: { wrappedValue.date },
            set: { wrappedValue = SherlockDate($0) }
        )
    }
}
