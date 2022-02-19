import SwiftUI

struct TextEditorWithPlaceholder: View
{
    @Binding var text: String

    private let placeholder: String

    @Environment(\.multilineTextAlignment)
    private var _placeholderAlignment: TextAlignment

    init(
        _ placeholder: String,
        text: Binding<String>
    )
    {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View
    {
        ZStack {
            if text.isEmpty {
                Text(placeholder)
                    .opacity(0.25)
                    .frame(maxWidth: .infinity, alignment: placeholderAlignment)
            }
            TextEditor(text: $text)
                .padding(.horizontal, -4) // Remove TextEditor's extra padding.
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var placeholderAlignment: Alignment
    {
        switch _placeholderAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}
