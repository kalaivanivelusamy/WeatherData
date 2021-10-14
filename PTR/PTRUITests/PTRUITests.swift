//
//  PTRUITests.swift
//  PTRUITests
//
//

import XCTest

class PTRUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testWeatherDataIsFetched(){
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.cells["Amsterdam"].children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["Weather"].tap()
        
        let weatherNavigationBar = app.navigationBars["Weather"]
        let refreshButton = weatherNavigationBar.buttons["Refresh"]
        refreshButton.tap()
        tablesQuery.cells["San Francisco"].children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        weatherNavigationBar.buttons["Weather"].tap()
        tablesQuery.cells["Budapest"].children(matching: .other).element(boundBy: 0).swipeDown()
        refreshButton.tap()
        
    }
}
