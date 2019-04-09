//
//  OMDBModelTests.swift
//  OMDBClientTests
//
//  Created by Amandeep on 06/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import XCTest
@testable import OMDBClient

class OMDBModelTests: XCTestCase {
    
    
    func testDate_Singular_Formatted_As_Years_Ago() {
        let toTest = Result(title: "Batman", year: "2018", imdbID: "1234", type: .movie, poster: "N/A")
        
        XCTAssertEqual(toTest.formattedDate, "1 year ago")
        
    }
    
    func testDate_SameYear_Formatted_As_Years_Ago() {
        let toTest = Result(title: "Batman", year: "2019", imdbID: "1234", type: .movie, poster: "N/A")
        
        XCTAssertEqual(toTest.formattedDate, "This year")
        
    }
    
    func testDate_Plural_Formatted_As_Years_Ago() {
        let toTest = Result(title: "Batman", year: "2017", imdbID: "1234", type: .movie, poster: "N/A")
        
        XCTAssertEqual(toTest.formattedDate, "2 years ago")
        
    }
    
    
    func testDateRange_SameYear_Formatted_As_Years_AgoRange() {
        let toTest = Result(title: "Batman", year: "2019–2019", imdbID: "1234", type: .movie, poster: "N/A")

        XCTAssertEqual(toTest.formattedDate, "This year")

    }
    
    func testDateRange_Singular_Formatted_As_Years_AgoRange() {
        let toTest = Result(title: "Batman", year: "2018–2019", imdbID: "1234", type: .movie, poster: "N/A")
        
        XCTAssertEqual(toTest.formattedDate, "1-0 year ago")
        
    }
    
    func testDateRange_Plural_Formatted_As_Years_AgoRange() {
        let toTest = Result(title: "Batman", year: "2017–2018", imdbID: "1234", type: .movie, poster: "N/A")
        
        XCTAssertEqual(toTest.formattedDate, "2-1 years ago")
        
    }

    
}
