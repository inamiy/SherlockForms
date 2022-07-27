import SwiftUI
import SherlockForms

/// Hierarchical `SwiftUI.List` example.
struct NestedListView: View, SherlockView
{
    @State public private(set) var searchText: String = ""

    @State private var items: [ListItem] = ListItem.presetItems

    var body: some View
    {
        SherlockForm(searchText: $searchText) {
            nestedList(
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

struct NestedListView_Previews: PreviewProvider
{
    static var previews: some View
    {
        NestedListView()
    }
}

// MARK: - Private

private struct ListItem: NestedListItem, Identifiable
{
    let content: String
    var children: [ListItem]?

    var id: String { content }

    init(content: String, children: [ListItem]?)
    {
        self.content = content
        self.children = children
    }

    static let presetItems: [ListItem] = (0 ... 3).map { i in
        ListItem(
            content: "Row \(i)",
            children: (0 ... 3).map { j in
                ListItem(
                    content: "Row \(i)-\(j)",
                    children: (0 ... 3).map { k in
                        ListItem(content: "Row \(i)-\(j)-\(k)", children: nil)
                    }
                )
            }
        )
    }
}
