import Foundation

/// Originally from https://github.com/noppefoxwolf/DebugMenu
class Network {
    private static func ifaddrs() -> [String] {
        var addresses = [String]()

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    var hostname: [CChar] = Array.init(repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(
                        &addr,
                        socklen_t(addr.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        socklen_t(0),
                        NI_NUMERICHOST
                    ) == 0 {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        return addresses
    }

    static func usage() -> NetworkUsage? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        var networkData: UnsafeMutablePointer<if_data>!

        var wifiDataSent: UInt64 = 0
        var wifiDataReceived: UInt64 = 0
        var wwanDataSent: UInt64 = 0
        var wwanDataReceived: UInt64 = 0

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let name = String(cString: ptr.pointee.ifa_name)
            let addr = ptr.pointee.ifa_addr.pointee

            guard addr.sa_family == UInt8(AF_LINK) else {
                continue
            }

            if name.hasPrefix("en") {
                networkData = unsafeBitCast(
                    ptr.pointee.ifa_data,
                    to: UnsafeMutablePointer<if_data>.self
                )
                wifiDataSent += UInt64(networkData.pointee.ifi_obytes)
                wifiDataReceived += UInt64(networkData.pointee.ifi_ibytes)
            }

            if name.hasPrefix("pdp_ip") {
                networkData = unsafeBitCast(
                    ptr.pointee.ifa_data,
                    to: UnsafeMutablePointer<if_data>.self
                )
                wwanDataSent += UInt64(networkData.pointee.ifi_obytes)
                wwanDataReceived += UInt64(networkData.pointee.ifi_ibytes)
            }
        }
        freeifaddrs(ifaddr)

        return .init(
            wifiDataSent: wifiDataSent,
            wifiDataReceived: wifiDataReceived,
            wwanDataSent: wwanDataSent,
            wwanDataReceived: wwanDataReceived
        )
    }
}

public struct NetworkUsage {
    public let wifiDataSent: UInt64
    public let wifiDataReceived: UInt64
    public let wwanDataSent: UInt64
    public let wwanDataReceived: UInt64

    public var sent: UInt64 { wifiDataSent + wwanDataSent }
    public var received: UInt64 { wifiDataReceived + wwanDataReceived }

    var prettyPrinted: String {

        func toString(_ bytes: UInt64) -> String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            formatter.allowsNonnumericFormatting = false
            return formatter.string(fromByteCount: Int64(bytes))
        }

        return """
            Wifi sent: \(toString(wifiDataSent))
            Wifi recv: \(toString(wifiDataReceived))
            WWAN sent: \(toString(wwanDataSent))
            WWAN recv: \(toString(wwanDataReceived))
            """
    }
}
