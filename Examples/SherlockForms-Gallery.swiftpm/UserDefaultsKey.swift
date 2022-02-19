enum UserDefaultsBoolKey: String, CaseIterable
{
    case lowPowerMode = "low-power-mode"
}

enum UserDefaultsStringKey: String, CaseIterable
{
    case username = "username"
    case email = "email"
    case password = "password"
    case status = "status"
    case testLongUserDefaults = "test-long-user-defaults"
}

enum UserDefaultsIntKey: String, CaseIterable
{
    case languageSelection = "language"
}

enum UserDefaultsDoubleKey: String, CaseIterable
{
    case speed = "speed"
    case fontSize = "font-size"
}

enum UserDefaultsDateKey: String, CaseIterable
{
    case birthday = "birthday"
    case alarm = "alarm"
}
