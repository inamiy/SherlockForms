import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func sliderCell<Value>(
        icon: Image? = nil,
        title: String,
        value: Binding<Value>,
        in bounds: ClosedRange<Value>,
        step: Value.Stride = 1,
        maxFractionDigits: Int? = nil,
        valueString: @escaping (_ value: String) -> String = { $0 },
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) -> SliderCell<EmptyView, EmptyView>
        where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint
    {
        SliderCell(
            icon: icon,
            title: title,
            value: value,
            in: bounds,
            step: step,
            maxFractionDigits: maxFractionDigits,
            valueString: valueString,
            sliderLabel: { EmptyView() },
            minimumValueLabel: { EmptyView() },
            maximumValueLabel: { EmptyView() },
            onEditingChanged: onEditingChanged,
            canShowCell: canShowCell
        )
    }

    @ViewBuilder
    public func sliderCell<Value, Label, ValueLabel>(
        icon: Image? = nil,
        title: String,
        value: Binding<Value>,
        in bounds: ClosedRange<Value>,
        step: Value.Stride = 1,
        maxFractionDigits: Int? = nil,
        valueString: @escaping (_ value: String) -> String = { $0 },
        sliderLabel: @escaping () -> Label,
        minimumValueLabel: @escaping () -> ValueLabel,
        maximumValueLabel: @escaping () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) -> SliderCell<Label, ValueLabel>
        where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint
    {
        SliderCell(
            icon: icon,
            title: title,
            value: value,
            in: bounds,
            step: step,
            maxFractionDigits: maxFractionDigits,
            valueString: valueString,
            sliderLabel: sliderLabel,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel,
            onEditingChanged: onEditingChanged,
            canShowCell: canShowCell
        )
    }
}

// MARK: - SliderCell

@MainActor
public struct SliderCell<Label, ValueLabel>: View
    where Label: View, ValueLabel: View
{
    private let icon: Image?
    private let title: String

    @Binding private var value: Double

    private let bounds: ClosedRange<Double>
    private let step: Double
    private let maxFractionDigits: Int?
    private let valueString: (_ value: String) -> String
    private let sliderLabel: () -> Label
    private let minimumValueLabel: () -> ValueLabel
    private let maximumValueLabel: () -> ValueLabel
    private let onEditingChanged: (Bool) -> Void
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    @Environment(\.formCellIconWidth)
    private var iconWidth: CGFloat?

    internal init<Value>(
        icon: Image? = nil,
        title: String,
        value: Binding<Value>,
        in bounds: ClosedRange<Value>,
        step: Value.Stride = 1,
        maxFractionDigits: Int? = nil,
        valueString: @escaping (_ value: String) -> String = { $0 },
        sliderLabel: @escaping () -> Label,
        minimumValueLabel: @escaping () -> ValueLabel,
        maximumValueLabel: @escaping () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
        where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint
    {
        self.icon = icon
        self.title = title
        self._value = Binding(
            get: { Double(value.wrappedValue) },
            set: { value.wrappedValue = Value($0) }
        )
        self.bounds = .init(
            uncheckedBounds: (lower: Double(bounds.lowerBound), upper: Double(bounds.upperBound))
        )
        self.step = Double(step)
        self.sliderLabel = sliderLabel
        self.maxFractionDigits = maxFractionDigits
        self.valueString = valueString
        self.minimumValueLabel = minimumValueLabel
        self.maximumValueLabel = maximumValueLabel
        self.onEditingChanged = onEditingChanged
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        let valueString_ = valueString("\(value.string(maxFractionDigits: maxFractionDigits))")

        VStackCell(
            keywords: [title, valueString_],
            canShowCell: canShowCell,
            copyableKeyValue: isCopyable ? .init(key: title, value: valueString_) : nil
        ) {
            HStack {
                icon.frame(minWidth: iconWidth, maxWidth: iconWidth)
                Text(title)
                Spacer()
                Text(valueString_)
                    .font(.body.monospacedDigit())
            }

            Slider(
                value: $value,
                in: bounds,
                step: step,
                label: sliderLabel,
                minimumValueLabel: minimumValueLabel,
                maximumValueLabel: maximumValueLabel,
                onEditingChanged: onEditingChanged
            )
        }
    }
}
