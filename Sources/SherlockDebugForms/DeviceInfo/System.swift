import Foundation

/// Originally from https://github.com/noppefoxwolf/DebugMenu
class System {
    static func uptime() -> time_t {
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride

        var now = time_t()
        var uptime: time_t = -1

        time(&now)
        if sysctl(&mib, 2, &boottime, &size, nil, 0) != -1 && boottime.tv_sec != 0 {
            uptime = now - boottime.tv_sec
        }
        return uptime
    }
}
