// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.

import SwiftUI

extension AnyView: @unchecked Sendable {}
extension Binding: @unchecked Sendable {}

extension UUID: @unchecked Sendable {}
