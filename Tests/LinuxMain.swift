#if os(Linux)
    
    import XCTest
    @testable import Api
    @testable import ApiTests
    
    var tests = [XCTestCaseEntry]()
    
    tests += DatabaseTests.allTests()
    tests += JSONTests.allTests()
    tests += ReferenceTests.allTests()
    
    XCTMain([tests])
#endif
