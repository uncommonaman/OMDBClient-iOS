//
//  OMDBClientTests.swift
//  OMDBClientTests
//
//  Created by Amandeep on 01/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import XCTest
@testable import OMDBClient

class OMDBClientTests: XCTestCase {
    var apiClient: OMDBClient!
    var url:URL!
    
    override func setUp() {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        apiClient = OMDBClient(session: session, delegate: nil)
        url = URL(string: "http://www.omdbapi.com/?s=Batman&page=1&apikey=eeefc96f")
        
    }

    override func tearDown() {
        apiClient = nil
    }
    
    
    
    func testAPIClient_InvalidURL() {
        apiClient.path = ""
        let exp = expectation(description: "Invalid url")
        apiClient.fetchSearchResults { result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.debugDescription, ApiError.invalidURL(string: "Invalid URL").debugDescription)
                
                
            }
        }
        wait(for: [exp], timeout: 3.0)
    }
    
    
    func testAPIClient_Not200_StatusCode() {
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        URLProtocolMock.testURLs = [url: Response.success(response, Data("This is test".utf8))]
        let exp = expectation(description: "Invalid url")
        apiClient.fetchSearchResults { result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                if case ApiError.invalidHTTPResponse(let response) = error {
                    XCTAssertEqual(error.debugDescription, "The HTTP request returned a corrupted HTTP response: \(response.debugDescription)")
                }
                
            }
        }
        wait(for: [exp], timeout: 3.0)
    }


    
    
    func testAPIClient_ConnectionError() {
        let error = NSError(domain: "connectionError", code: 999, userInfo: nil)
        URLProtocolMock.testURLs = [url: Response.failure(error)]
        let exp = expectation(description: "Connection error")
        apiClient.fetchSearchResults { result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.debugDescription, ApiError.connectionError(message: "The operation couldn’t be completed. (connectionError error 999.)").debugDescription)
                
                
            }
        }
        wait(for: [exp], timeout: 3.0)
    }

    
    
    func testAPIClient_Failure_ParsingData_on200Status() {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        URLProtocolMock.testURLs = [url: Response.success(response, Data("This is test".utf8))]
        let exp = expectation(description: "Fetches data")
        apiClient.fetchSearchResults { result in
            exp.fulfill()
            switch result {
            case .success(_):
                XCTFail()
            case .failure(let error):
                print(error.debugDescription)
                XCTAssertEqual(error.debugDescription, ApiError.parsingError(data: nil, errorMessage: "Parsing error").debugDescription)
            }
        }
        wait(for: [exp], timeout: 3.0)
    }
    
    
    func testAPIClient_Successfully_ParsesData_on200Status() {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        URLProtocolMock.testURLs = [url: .success(response, URLProtocolMock.stubbedResponse())]
        let exp = expectation(description: "Parses data")
        apiClient.fetchSearchResults { result in
            exp.fulfill()
            switch result {
            case .success(let res):
                let total = self.apiClient.total
                XCTAssertEqual(total, 361)
                
            case .failure(let error):
                print(error.debugDescription)
                XCTFail()
                
            }
        }
        wait(for: [exp], timeout: 3.0)
    }
    
    func testAPIClient_ReturnsFalse_InvalidAPIResponse() {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let result = Result(title: "Batman", year: "2015", imdbID: "1234", type: .movie, poster: "N/A")
        let encodable = OMDBModel(results: [result], totalResults: "361", response: "False")
        let jsonEncoder = JSONEncoder()
        let data = try! jsonEncoder.encode(encodable)
        URLProtocolMock.testURLs = [url: .success(response, data)]
        let exp = expectation(description: "Invalid API Response ")
        apiClient.fetchSearchResults { result in
            exp.fulfill()
            switch result {
            case .success(_ ):
                XCTFail()
                
            case .failure(let error):
                XCTAssertEqual(error.debugDescription, ApiError.invalidApiResponse(message: "Invalid Response").debugDescription)
            }
        }
        wait(for: [exp], timeout: 3.0)
    }
    
    func testAPIClient_ReturnsEmptyArray_InvalidAPIResponse() {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
       //  let result = Result(title: "Batman", year: "2015", imdbID: "1234", type: .movie, poster: "N/A")
        let encodable = OMDBModel(results: [], totalResults: "361", response: "True")
        let jsonEncoder = JSONEncoder()
        let data = try! jsonEncoder.encode(encodable)
        URLProtocolMock.testURLs = [url: .success(response, data)]
        let exp = expectation(description: "Invalid API Response ")
        apiClient.fetchSearchResults { result in
            exp.fulfill()
            switch result {
            case .success(_ ):
                XCTFail()
                
            case .failure(let error):
                XCTAssertEqual(error.debugDescription, ApiError.invalidApiResponse(message: "No results found").debugDescription)
            }
        }
        wait(for: [exp], timeout: 3.0)
    }


    
    
    
 
    
    

   

}
