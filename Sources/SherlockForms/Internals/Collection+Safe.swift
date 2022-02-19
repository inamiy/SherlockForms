extension Collection
{
    subscript (safe index: Index) -> Iterator.Element?
    {
        return self.startIndex <= index && index < self.endIndex
            ? self[index]
            : nil
    }

    subscript <R: RangeExpression>(safe range: R) -> SubSequence?
        where R.Bound == Index
    {
        let r = range.relative(to: self)
        return r.lowerBound >= self.startIndex && r.upperBound <= self.endIndex
            ? self[range]
            : nil
    }
}
