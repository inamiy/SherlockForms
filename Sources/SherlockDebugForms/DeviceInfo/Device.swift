import UIKit

/// Originally from https://github.com/noppefoxwolf/DebugMenu
@MainActor
public class Device {
    public static let current: Device = .init()

    public var localizedModel: String {
        UIDevice.current.localizedModel
    }

    public var model: String {
        UIDevice.current.model
    }

    public var name: String {
        UIDevice.current.name
    }

    public var systemName: String {
        UIDevice.current.systemName
    }

    public var systemVersion: String {
        UIDevice.current.systemVersion
    }

    public var localizedBatteryLevel: String {
        "\(batteryLevel * 100.00) %"
    }

    public var batteryLevel: Float {
        UIDevice.current.batteryLevel
    }

    public var batteryState: UIDevice.BatteryState {
        UIDevice.current.batteryState
    }

    public var localizedBatteryState: String {
        switch batteryState {
        case .unknown: return "unknown"
        case .unplugged: return "unplugged"
        case .charging: return "charging"
        case .full: return "full"
        @unknown default: return "default"
        }
    }

    public var isJailbreaked: Bool {
        FileManager.default.fileExists(atPath: "/private/var/lib/apt")
    }

    public var thermalState: ProcessInfo.ThermalState {
        ProcessInfo.processInfo.thermalState
    }

    public var localizedThermalState: String {
        switch thermalState {
        case .nominal: return "nominal"
        case .fair: return "fair"
        case .serious: return "serious"
        case .critical: return "critical"
        @unknown default: return "default"
        }
    }

    public var processorCount: Int {
        ProcessInfo.processInfo.processorCount
    }

    public var activeProcessorCount: Int {
        ProcessInfo.processInfo.activeProcessorCount
    }

    public var processor: String {
        "\(activeProcessorCount) / \(processorCount)"
    }

    public var isLowPowerModeEnabled: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    public var physicalMemory: UInt64 {
        ProcessInfo.processInfo.physicalMemory
    }

    public var localizedPhysicalMemory: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: Int64(physicalMemory))
    }

    // without sleep time
    public var systemUptime: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }

    // include sleep time
    public func uptime() -> time_t {
        System.uptime()
    }

    public var localizedSystemUptime: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter.string(from: systemUptime) ?? "-"
    }

    public var localizedUptime: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter.string(from: TimeInterval(uptime())) ?? "-"
    }

    public var diskTotalSpace: Int64 {
        if let attributes = try? FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
        ) {
            return attributes[.systemSize] as! Int64
        } else {
            return 0
        }
    }

    public var diskFreeSpace: Int64 {
        if let attributes = try? FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
        ) {
            return attributes[.systemFreeSize] as! Int64
        } else {
            return 0
        }
    }

    public var diskUsage: Int64 {
        diskTotalSpace - diskFreeSpace
    }

    public var localizedDiskUsage: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowsNonnumericFormatting = false
        return "\(formatter.string(fromByteCount: diskUsage)) / \(formatter.string(fromByteCount: diskTotalSpace))"
    }

    public var localizedMemoryUsage: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: Int64(memoryUsage()))
    }

    public func memoryUsage() -> UInt64 {
        Memory.usage()
    }

    public var localizedCPUUsage: String {
        String(format: "%.1f%%", cpuUsage() * 100.0)
    }

    public func cpuUsage() -> Double {
        CPU.usage()
    }

    public func networkUsage() -> NetworkUsage? {
        Network.usage()
    }

    public var localizedGPUMemory: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: Int64(GPU.current.currentAllocatedSize))
    }
}
