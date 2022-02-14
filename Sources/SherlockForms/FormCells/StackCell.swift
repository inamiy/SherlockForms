import SwiftUI

// MARK: - Constructors

extension SherlockView
{
     /// `HStackCell` that can become visible or hidden depending on `searchText`.
    @ViewBuilder
    public func hstackCell<Content: View>(
        keywords: String...,
        copyableKeyValue: FormCellCopyableKeyValue? = nil,
        alignment: VerticalAlignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) -> HStackCell<Content>
    {
        ContainerCell<HStack<Content>, Content>(
            keywords: keywords,
            canShowCell: canShowCell,
            copyableKeyValue: copyableKeyValue,
            alignment: alignment,
            content: content
        )
    }

    /// `VStackCell` that can become visible or hidden depending on `searchText`.
    @ViewBuilder
    public func vstackCell<Content: View>(
        keywords: String...,
        copyableKeyValue: FormCellCopyableKeyValue? = nil,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping () -> Content
    ) -> VStackCell<Content>
    {
        VStackCell<Content>(
            keywords: keywords,
            canShowCell: canShowCell,
            copyableKeyValue: copyableKeyValue,
            alignment: alignment,
            content: content
        )
    }
}

// MARK: - HStackCell / VStackCell

public typealias HStackCell<Content: View> = ContainerCell<HStack<Content>, Content>
public typealias VStackCell<Content: View> = ContainerCell<VStack<Content>, Content>
