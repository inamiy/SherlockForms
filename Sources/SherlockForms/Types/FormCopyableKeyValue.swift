/// "Copy Key" / "Copy Value" pair.
/// - Note: If `value` is `nil`, `key` will be used as canonical "Copy".
public struct FormCellCopyableKeyValue
{
    public var key: String
    public var value: String?

    public init(key: String, value: String? = nil)
    {
        self.key = key
        self.value = value
    }
}
