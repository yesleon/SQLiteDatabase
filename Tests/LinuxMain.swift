import XCTest

import SQLiteDatabaseTests

var tests = [XCTestCaseEntry]()
tests += SQLiteDatabaseTests.allTests()
XCTMain(tests)
