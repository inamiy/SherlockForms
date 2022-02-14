/// A protocol that interacts with ``SherlockForm``.
@MainActor
public protocol SherlockView
{
    /// Current searching text.
    var searchText: String { get }

    /// Compares `keywords` with `searchText`.
    func canShowCell(keywords: [String]) -> Bool
}

// MARK: - Default implementation

extension SherlockView
{
    // Default implementation.
    public func canShowCell(keywords: [String]) -> Bool
    {
        if searchText.isEmpty { return true }

        for keyword in keywords {
            if keyword.lowercased().contains(searchText.lowercased()) {
                return true
            }
        }

        return false
    }

    public func canShowCell(keywords: String...) -> Bool
    {
        canShowCell(keywords: keywords)
    }
}
