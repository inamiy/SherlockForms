import SwiftUI

/// Single key-value pair viewer for `UserDefaults`.
struct UserDefaultsItemView: View, SherlockView
{
    // TODO: Add custom filtering to search per line.
    @State var searchText: String = ""

    @State private var canEditAsString: Bool = false

    // TODO: Replace with `\.dismiss` for iOS 15.
    @Environment(\.presentationMode) private var presentationMode

    private let key: String
    private let value: Any
    private var editableString: AppStorage<String>

    init(key: String, value: Any, userDefaults: UserDefaults = .standard)
    {
        self.key = key
        self.value = value

        if let value = value as? String {
            self.editableString = AppStorage(wrappedValue: value, key, store: userDefaults)
            self.canEditAsString = true
        }
        else {
            self.editableString = AppStorage(wrappedValue: "\(value)", key, store: userDefaults)
            self.canEditAsString = false
        }
    }

    var body: some View
    {
        NavigationView {
            SherlockForm(searchText: $searchText) {
                _body(canEditAsString: canEditAsString)
            }
            .formCellCopyable(true)
            .navigationTitle(key)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                        Image(systemName: "xmark")
                    })
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    if !canEditAsString {
                        Spacer()
                        Button(action: { canEditAsString = true }, label: {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Edit as String (Unsafe)")
                        })
                        Spacer()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func _body(canEditAsString: Bool) -> some View
    {
        Section {
            textCell(title: "\(key)")
        } header: {
            Text("Key")
        }

        Section {
            textCell(title: "\(type(of: value))")
        } header: {
            Text("Type")
        }

        Section {
            textEditorCell(value: editableString.projectedValue, modify: { textEditor in
                textEditor
                    .padding(canEditAsString ? 8 : 0)
                    .disabled(!canEditAsString)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(canEditAsString ? 0.25 : 0), lineWidth: 0.5)
                    )
                    .onChange(of: canEditAsString, perform: { canEditAsString in
                        // NOTE:
                        // Set the `editableString.wrappedValue` to tell `textEditor`
                        // to update its scroll content.
                        if canEditAsString {
                            editableString.wrappedValue = editableString.wrappedValue
                        }
                    })
            })
        } header: {
            Text("Value")
        } footer: {
            if !canEditAsString {
                Text("""
                    Note:
                    Smart type recognition is not supported yet. To (unsafely) edit value as string, tap bottom button.
                    """)
                    .padding(.top, 16)
            }
        }
    }

    typealias KeyValue = UserDefaultsListSectionsView.KeyValue
}
