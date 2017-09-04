import XCTest
@testable import Api
@testable import ApiTests

XCTMain([
    testCase(DatabaseTests.allTests),
    testCase(JSONTests.allTests),
    testCase(ReferenceTests.allTests)
])
