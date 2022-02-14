extension String
{
    func truncated(maxCount: Int, trailing: String = "…") -> String
    {
        (self.count > maxCount) ? self.prefix(maxCount) + trailing : self
    }
}
