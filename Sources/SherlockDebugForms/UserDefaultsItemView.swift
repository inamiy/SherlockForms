import SwiftUI

/// Single key-value pair viewer for `UserDefaults`.
struct UserDefaultsItemView: View, SherlockView
{
    // TODO: Add custom filtering to search per line.
    @State var searchText: String = ""

    // TODO: Replace with `\.dismiss` for iOS 15.
    @Environment(\.presentationMode) private var presentationMode

    private var keyValue: Binding<KeyValue>

    init(keyValue: Binding<KeyValue>)
    {
        self.keyValue = keyValue
    }

    var body: some View
    {
        NavigationView {
            SherlockForm(searchText: $searchText) {
                _body
            }
            .formCellCopyable(true)
            .navigationTitle(keyValue.wrappedValue.key)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
    }

    @ViewBuilder
    private var _body: some View
    {
        let key = keyValue.wrappedValue.key
        let value = keyValue.wrappedValue.value

        Section {
            textCell(title: key)
        } header: {
            Text("Key")
        }

        Section {
            textCell(title: "\(String(describing: value))")
        } header: {
            Text("Value")
        }
    }

    typealias KeyValue = UserDefaultsListSectionsView.KeyValue
}
