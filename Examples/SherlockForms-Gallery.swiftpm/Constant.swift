enum Constant
{
    static let loremIpsum = """
        Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """

    static let languages: [String] = [
        "English",
        "Japanease",
        "French",
        "Chinese"
    ]

    enum Status: String, CaseIterable, Hashable {
        case online = "Online"
        case away = "Away"
        case offline = "Offline"
    }
}
