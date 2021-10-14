//
//  PTRTests.swift
//  PTRTests
//
//

import XCTest
@testable import PTR

class PTRTests: XCTestCase {

    var sut = NetworkManager()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetWeatherAPIWithNilError() {
        var weatherData: [WeatherModel]?
        sut.getWeather{ result, error in
            weatherData = result
            XCTAssertEqual(error,nil)
            XCTAssertTrue(result!.count > 0)
        }
    }
    
    func testGetWeatherAPIWithResponseData() {
         sut.getWeather{ result, error in
             XCTAssertTrue(result!.count > 0)
         }        
    }

}


