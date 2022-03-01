import SwiftUI

/// Smart `.searchable` SwiftUI `Form`.
/// - Note: `.searchable` is available only from iOS 15 or above, but still compiles for older OS versions.
@MainActor
public struct SherlockForm<Content: View>: View
{
    private let searchText: Binding<String>
    private let formBuilder: (() -> Content) -> AnyView
    private let content: () -> Content

    public init<FormLike: View>(
        searchText: Binding<String>,
        formBuilder: @escaping (() -> Content) -> FormLike,
        @ViewBuilder content: @escaping () -> Content
    )
    {
        self.searchText = searchText
        self.formBuilder = { AnyView(formBuilder($0)) }
        self.content = content
    }

    /// Initializer with `formBuilder` being specialized to `Form`.
    public init(
        searchText: Binding<String>,
        @ViewBuilder _ content: @escaping () -> Content
    )
    {
        self.init(
            searchText: searchText,
            formBuilder: { content in AnyView(Form { content() }) },
            content: content
        )
    }

    public var body: some View
    {
        let form = formBuilder { content() }

        if #available(iOS 15.0, *) {
            form
                .searchable(
                    text: searchText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: Text("Search")
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onSubmit(of: .search) {
                    hideKeyboard()
                }
        }
        else {
            // FIXME: No searching support for iOS 14 yet.
            form
        }
    }
}
