import SwiftUI
import SherlockForms

/// Simple `SwiftUI.List` example.
struct ListView: View, SherlockView
{
    @State public private(set) var searchText: String = ""

    @State private var items: [ListItem] = (0 ... 3).map { ListItem(content: "Row \($0)") }

    var body: some View
    {
        SherlockForm(searchText: $searchText) {
            simpleList(
                data: items,
                rowContent: { item in
                    Text("\(item.content)")
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .formCellCopyable(true)
    }
}

// MARK: - Previews

struct ListView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ListView()
    }
}

// MARK: - Private

private struct ListItem: SimpleListItem, Identifiable
{
    let content: String

    var id: String { content }
}
