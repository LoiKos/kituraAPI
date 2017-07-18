import Foundation
#if os(Linux)
    import Glibc
#endif

/**
 This singleton is used to create reference for products and stores.
 you can add a suffix or prefix before generating the reference that allow you to customize it as you wish.
 Reference can be created with or without a size parameter. The minimum size of the reference is 10 characters and by default the reference is 15 characters.
 */

open class Reference {
    
    // Singleton
    open static let sharedInstance : Reference = {
        let instance = Reference()
        #if os(Linux)
            srand(UInt32(time(nil)))
        #endif
        return instance
    }()
    
    // Variables
    private let charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters.map { String($0) }
    private var prefix : String = ""
    private var suffix : String = ""
    
    
    
    /// add a prefix to the next generated reference
    open func prefix(_ prefix: String) -> Reference {
        self.prefix = prefix
        return self
    }
    
    /// add a suffix to the next generated reference
    open func suffix(_ suffix: String) -> Reference {
        self.suffix = suffix
        return self
    }
    
    /// Default function to generate Reference without specifications. the reference length will be 15 characters.
    open func generateRef() -> String {
        var reference = prefix
        
        for _ in 0...14 {
            #if os(Linux)
                reference.append(charSet[random() % charSet.count])
            #else
                reference.append(charSet[Int(arc4random_uniform(UInt32(charSet.count)))])
            #endif
        }
        
        reference.append(suffix)
        self.clear()
        return reference
    }
    
    /// Generate a reference with size specification. Minimum length is 10 characters.
    open func generateRef(size:Int) throws -> String {
        
        guard size > 10 else {
            throw ReferenceError.wrongSize
        }
        
        var reference = prefix
        
        for _ in 0...size - 1 {
            #if os(Linux)
                reference.append(charSet[random() % charSet.count])
            #else
                reference.append(charSet[Int(arc4random_uniform(UInt32(charSet.count)))])
            #endif
        }
        
        reference.append(suffix)
        self.clear()
        return reference
    }
    
    /// remove value you could have provide to prefix / suffix
    internal func clear() {
        if prefix != "" {
            prefix = ""
        }
        
        if suffix != "" {
            suffix = ""
        }
    }
}

// Error Handler for Reference class
public enum ReferenceError : Error{
    case wrongSize
}
