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

#if compiler(>=5.5)
extension View {
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    func confirmationDialog<Value, A: View, M: View>(
        title: (Value) -> Text,
        titleVisibility: Visibility = .automatic,
        unwrapping value: Binding<Value?>,
        @ViewBuilder actions: @escaping (Value) -> A,
        @ViewBuilder message: @escaping (Value) -> M
    ) -> some View {
        self.confirmationDialog(
            value.wrappedValue.map(title) ?? Text(""),
            isPresented: value.isPresent(),
            titleVisibility: titleVisibility,
            presenting: value.wrappedValue,
            actions: actions,
            message: message
        )
    }
}
#endif
