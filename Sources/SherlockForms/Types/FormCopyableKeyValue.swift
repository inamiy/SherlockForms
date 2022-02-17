/// "Copy Key" / "Copy Value" pair.
/// - Note: If `key` or `value` is `nil`, the remaining string will be used as canonical "Copy".
public struct FormCellCopyableKeyValue
{
    public var key: String?
    public var value: String?

    public init(key: String? = nil, value: String? = nil)
    {
        self.key = key
        self.value = value
    }
}
