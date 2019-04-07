//
//  OMDBClient.swift
//  OMDBClient
//
//  Created by Amandeep on 07/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation


protocol PaginationDelegate: class {
    func didAddPage(indexPaths:[IndexPath])
    func didFailFetchingNextPage(error: ApiError,pageNumber:Int)
}


enum ApiResult<T: Decodable> {
    case success(T)
    case failure(ApiError)
}

enum ApiError: Error, CustomDebugStringConvertible {
    
    case parsingError(data: Data?, errorMessage: String)
    case invalidHTTPResponse(response: URLResponse?)
    case invalidURL(string: String)
    case invalidApiResponse(message: String)
    case connectionError(message: String)
    
    
    var debugDescription: String {
        return message
    }
    
    private var message: String {
        switch self {
        case .invalidURL(let string):
            return string
        case .invalidHTTPResponse(let response):
            return "The HTTP request returned a corrupted HTTP response: \(response.debugDescription)"
        case .parsingError(_, let errorMessage):
            return errorMessage
        case .invalidApiResponse(let message):
            return message
        case .connectionError(let message):
            return message
            
        }
    }
}


class OMDBClient {
    private let session: URLSession
    private let searchKeyWord = "Batman"
    private let apiKey = "eeefc96f"
    private let basePath = "http://www.omdbapi.com"
    lazy var path = "\(basePath)/?s=\(searchKeyWord)&page=\(currentPage)&apikey=\(apiKey)"
    private var isFetchingNextPage = false
    var currentPage = 1
    var content: [Result]?
    var total = 0
    weak var delegate: PaginationDelegate?
    
    init(session:URLSession,delegate:PaginationDelegate?) {
        self.session = session
        self.delegate = delegate
    }
    
    
    
    typealias ApiCompletionBlock<T: Decodable> = (ApiResult<T>) -> Void
    func fetchSearchResults(completion: @escaping ApiCompletionBlock<[Result]>) {
        
        
        
        guard let url = URL(string: path) else {
            completion(ApiResult.failure(ApiError.invalidURL(string: "Invalid URL")))
            return
        }
        isFetchingNextPage = true
        self.session.dataTask(with: url) { data, response, error in
            if let e = error {
                DispatchQueue.main.async {
                    completion(ApiResult.failure(.connectionError(message: e.localizedDescription)))
                }
            } else {
                let http = response as! HTTPURLResponse
                switch http.statusCode {
                case 200 :
                    let jsonDecoder = JSONDecoder()
                    do {
                        let omdbModel = try jsonDecoder.decode(OMDBModel.self, from: data!) //data is usually there
                        DispatchQueue.main.async {
                            if omdbModel.response == "True"  {
                                if omdbModel.results.count > 0 {
                                    
                                    //completion(ApiResult.success(omdbModel.results))
//                                    if let content = self.content {
//
//                                    }
//                                    else {
                                    guard let content = self.content else {
                                            self.total = Int(omdbModel.totalResults) ?? 0
                                           self.content = omdbModel.results
                                          completion(ApiResult.success(omdbModel.results))
                                        return
                                        
                                    }
                                    
                                    
                                    
                                        completion(ApiResult.success(omdbModel.results))
                                   // }
                                   
                                }
                                else {
                                    completion(ApiResult.failure(ApiError.invalidApiResponse(message: "No results found")))
                                }
                            }
                            else {
                                completion(ApiResult.failure(ApiError.invalidApiResponse(message: "Invalid Response")))
                            }
                        }
                    }
                    catch {
                        DispatchQueue.main.async {
                            completion(ApiResult.failure(ApiError.parsingError(data: data, errorMessage: "Parsing error")))
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        completion(ApiResult.failure(.invalidHTTPResponse(response: response)))
                    }
                }
                
            }
            self.isFetchingNextPage = false
        }.resume()
    }
    
     func fetchNextPage() {
        guard !isFetchingNextPage else { return }
        guard let content = content else { return }
        currentPage += 1
        fetchSearchResults { result in
            switch result {
            case .success(let newPage):
                self.content!.append(contentsOf: newPage)
                let addedIndexPaths = self.indexPathsToUpdate(newPage: newPage)
                self.delegate?.didAddPage(indexPaths: addedIndexPaths)
                
            case .failure(let error):
                //completion(ApiResult.failure(error))
                self.delegate?.didFailFetchingNextPage(error: error, pageNumber: self.currentPage)
            }
            
        }
    }
    
    private func indexPathsToUpdate(newPage:[Result]) -> [IndexPath] {
        let startIndex = self.content!.count - newPage.count - 1
        let endIndex = self.content!.count - 1
        
        let newIndexPaths = (startIndex...endIndex).map { i in
            return IndexPath(row: i, section: 0)
        }
        return newIndexPaths
    }
}
