import SwiftUI

struct TextEditorWithPlaceholder: View
{
    @Binding var text: String

    private let placeholder: String

    init(_ placeholder: String, text: Binding<String>)
    {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View
    {
        ZStack {
            if text.isEmpty {
                Text(placeholder).opacity(0.25)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            TextEditor(text: $text)
                .padding(.horizontal, -4) // Remove TextEditor's extra padding.
        }
    }
}
