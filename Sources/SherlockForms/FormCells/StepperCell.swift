import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func stepperCell(
        icon: Image? = nil,
        title: String,
        value: Binding<Double>,
        in bounds: ClosedRange<Double>,
        step: Double = 1,
        maxFractionDigits: Int? = nil,
        valueString: @escaping (_ value: String) -> String = { $0 }
    ) -> StepperCell
    {
        StepperCell(
            icon: icon,
            title: title,
            value: value,
            in: bounds,
            step: step,
            maxFractionDigits: maxFractionDigits,
            valueString: valueString,
            canShowCell: canShowCell
        )
    }
}

// MARK: - StepperCell

@MainActor
public struct StepperCell: View
{
    private let icon: Image?
    private let title: String
    @Binding private var value: Double
    private var bounds: ClosedRange<Double>
    private var step: Double
    private let maxFractionDigits: Int?
    private let valueString: (_ value: String) -> String
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    internal init(
        icon: Image? = nil,
        title: String,
        value: Binding<Double>, // TODO: Binding<Value> where Value: Strideable
        in bounds: ClosedRange<Double>,
        step: Double = 1,
        maxFractionDigits: Int? = nil,
        valueString: @escaping (_ value: String) -> String = { $0 },
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self._value = value
        self.bounds = bounds
        self.step = step
        self.maxFractionDigits = maxFractionDigits
        self.valueString = valueString
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        let valueString_ = valueString("\(value.string(maxFractionDigits: maxFractionDigits))")

        HStackCell(
            keywords: [title, valueString_],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: valueString_) : nil
        ) {
            Text(title)
            Spacer()

            // Value-printing.
            Text(valueString_)
                .font(.body.monospacedDigit())

            // NOTE: Set `label` as empty for customized text layout i.e. `title` and `valueString_`.
            Stepper(value: $value, in: bounds, step: step, label: {})
                .fixedSize() // Required to allow above `Spacer` to work correctly.
        }
    }
}
