import SwiftUI
import Combine

public struct DeviceInfoView: View, SherlockView
{
    @StateObject private var timer: TimerWrapper = .init()

    @State public var searchText: String = ""

    public init() {}

    public var body: some View
    {
        SherlockForm(searchText: $searchText) {
            _body
        }
        .formCellCopyable(true)
        .navigationTitle("Device Info")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var _body: some View
    {
        Section {
            textCell(title: "Model", value: Device.current.localizedModel)
            textCell(title: "Name", value: Device.current.name)
            textCell(title: "System Name", value: Device.current.systemName)
            textCell(title: "System Version", value: Device.current.systemVersion)
            textCell(title: "Jailbreak?", value: Device.current.isJailbreaked)
            textCell(title: "Low Power Mode?", value: Device.current.isLowPowerModeEnabled)
        } header: {
            Text("General")
        }

        Section {
            textCell(title: "Processor", value: Device.current.processor)
            textCell(title: "Disk", value: Device.current.localizedDiskUsage)
            textCell(title: "Memory", value: "\(Device.current.localizedMemoryUsage) / \(Device.current.localizedPhysicalMemory)")
            textCell(title: "CPU", value: Device.current.localizedCPUUsage)
            textCell(title: "GPU Memory", value: Device.current.localizedGPUMemory)
            textCell(title: "Network", value: Device.current.networkUsage()?.prettyPrinted ?? "")
            textCell(title: "Battery", value: "\(Device.current.localizedBatteryLevel) / \(Device.current.localizedBatteryState)")
            textCell(title: "Thermal State", value: Device.current.localizedThermalState)
        } header: {
            Text("Usage")
        }

        Group {
            textCell(title: "System uptime", value: Device.current.localizedSystemUptime)
            textCell(title: "Uptime", value: Device.current.localizedUptime)
        }
    }
}

private final class TimerWrapper : ObservableObject
{
    let objectWillChange = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {}
}
