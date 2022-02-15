import SwiftUI

// MARK: - Constructors

extension SherlockView
{
    @ViewBuilder
    public func navigationLinkCell<Destination>(
        icon: Image? = nil,
        title: String,
        @ViewBuilder destination: @MainActor @escaping () -> Destination
    ) -> NavigationLinkCell<Destination>
        where Destination: View
    {
        NavigationLinkCell(icon: icon, title: title, destination: destination, canShowCell: canShowCell)
    }
}

// MARK: - NavigationLinkCell

@MainActor
public struct NavigationLinkCell<Destination>: View
    where Destination: View
{
    private let icon: Image?
    private let title: String
    private let destination: @MainActor () -> Destination
    private let canShowCell: @MainActor (_ keywords: [String]) -> Bool

    @Environment(\.formCellCopyable)
    private var isCopyable: Bool

    @Environment(\.formCellContentModifier)
    private var formCellContentModifier: AnyViewModifier

    internal init(
        icon: Image? = nil,
        title: String,
        @ViewBuilder destination: @MainActor @escaping () -> Destination,
        canShowCell: @MainActor @escaping (_ keywords: [String]) -> Bool = { _ in true }
    )
    {
        self.icon = icon
        self.title = title
        self.destination = destination
        self.canShowCell = canShowCell
    }

    public var body: some View
    {
        if canShowCell([title]) {
            _body
        }
    }

    @ViewBuilder
    private var _body: some View
    {
        let link = NavigationLink(destination: LazyView(destination()), label: {
            icon
            Text(title)
        })
            .modifier(formCellContentModifier)

        if isCopyable {
            link.modifier(CopyableViewModifier(key: title))
        }
        else {
            link
        }
    }
}
