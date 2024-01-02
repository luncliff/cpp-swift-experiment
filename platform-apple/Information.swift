import Foundation

import Baguette

/// Create an `Information` object to get the details
class Information {
    public let version: UInt32;
    
    public init() {
        var output : UInt32 = 0
        // C++ namespace `experimental` became Swift public enum
        experiment.get_version(&output)
        self.version = output
    }
}
