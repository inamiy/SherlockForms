import Foundation

/// Originally from https://github.com/noppefoxwolf/DebugMenu
class CPU {
    static func usage() -> Double {
        let ids = threadIDs()
        var totalUsage: Double = 0
        for id in ids {
            let usage = threadUsage(id: id)
            totalUsage += usage
        }
        return totalUsage
    }

    static func threadIDs() -> [thread_inspect_t] {
        var threadList: thread_act_array_t?
        var threadCount = UInt32(
            MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size
        )
        let result = task_threads(mach_task_self_, &threadList, &threadCount)
        if result != KERN_SUCCESS { return [] }
        var ids: [thread_inspect_t] = []
        for index in (0..<Int(threadCount)) {
            ids.append(threadList![index])
        }
        return ids
    }

    static func threadUsage(id: thread_inspect_t) -> Double {
        var threadInfo = thread_basic_info()
        var threadInfoCount = UInt32(THREAD_INFO_MAX)
        let result = withUnsafeMutablePointer(to: &threadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                thread_info(id, UInt32(THREAD_BASIC_INFO), $0, &threadInfoCount)
            }
        }
        // スレッド情報が取れない = 該当スレッドのCPU使用率を0とみなす(基本nilが返ることはない)
        if result != KERN_SUCCESS { return 0 }
        let isIdle = threadInfo.flags == TH_FLAGS_IDLE
        // CPU使用率がスケール調整済みのため`TH_USAGE_SCALE`で除算し戻す
        return !isIdle ? Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) : 0
    }
}
