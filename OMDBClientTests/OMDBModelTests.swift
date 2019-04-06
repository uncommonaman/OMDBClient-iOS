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
    
    
    func testDate_Always_Formatted_As_Years_Ago() {
        let toTest = Result(title: "Batman", year: "2016", imdbID: "1234", type: .movie, poster: "N/A")
        
        XCTAssertEqual(toTest.formattedDate, "3 years ago")
        
    }

 

}
