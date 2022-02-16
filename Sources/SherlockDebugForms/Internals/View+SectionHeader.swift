import SwiftUI

extension View
{
    @ViewBuilder
    func sectionHeaderView(_ text: String) -> some View
    {
        if text.isEmpty { EmptyView() }
        else { Text(text) }
    }
}
