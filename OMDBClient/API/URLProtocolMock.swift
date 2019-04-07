//
//  URLProtocolMock.swift
//  OMDBClient
//
//  Created by Amandeep on 07/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation

enum Response {
    case success(URLResponse,Data)
    case failure(NSError)
}

class URLProtocolMock: URLProtocol {
    static var testURLs = [URL: Response]()

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            if let response = URLProtocolMock.testURLs[url] {
                switch response {
                case .success(let res,let data):
                    client?.urlProtocol(self, didReceive: res, cacheStoragePolicy: .allowed)
                    client?.urlProtocol(self, didLoad: data)
                case .failure(let error):
                    client?.urlProtocol(self, didFailWithError: error)
                    
                }
            }
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
  
    override func stopLoading() { }
    
    
    static func stubbedResponse() -> Data {
        let url = Bundle.main.url(forResource: "stubbedResponse", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }
}

