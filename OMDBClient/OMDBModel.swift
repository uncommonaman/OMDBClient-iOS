//
//  OMDBModel.swift
//  OMDBClient
//
//  Created by Amandeep on 02/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation

struct OMDBModel: Codable {
    var search: [Search]
    let totalResults, response: String
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
    var totalCount: Int{
        return Int(totalResults) ?? 0
    }
    
}

struct Search: Codable {
    let title, year, imdbID: String
    let type: TypeEnum
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
    
    var posterURL:URL? {
        return URL(string: poster)
    }
}

enum TypeEnum: String, Codable {
    case game = "game"
    case movie = "movie"
    case series = "series"
    
   
}

