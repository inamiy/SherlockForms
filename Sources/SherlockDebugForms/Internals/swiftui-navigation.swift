// Originally from https://github.com/pointfreeco/swiftui-navigation
// with `internal` access modifier.

import SwiftUI

extension Binding {
    init?(unwrapping base: Binding<Value?>) {
        guard let value = base.wrappedValue else {
            return nil
        }

        self = Binding<Value>(
            get: { value },
            set: { base.wrappedValue = $0 }
        )
    }

    func isPresent<Wrapped>() -> Binding<Bool>
    where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresent, transaction in
                if !isPresent {
                    self.transaction(transaction).wrappedValue = nil
                }
            }
        )
    }
}

extension View {
    func sheet<Value, Content>(
        unwrapping value: Binding<Value?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) -> some View
    where Content: View {
        self.sheet(isPresented: value.isPresent(), onDismiss: onDismiss) {
            Binding(unwrapping: value).map(content)
        }
    }
}
