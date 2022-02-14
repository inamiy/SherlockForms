import Metal

/// Originally from https://github.com/noppefoxwolf/DebugMenu
class GPU {
    static var current: GPU = .init()
    let device: MTLDevice

    init() {
        device = MTLCreateSystemDefaultDevice()!
    }

    var currentAllocatedSize: Int {
        device.currentAllocatedSize
    }
}
