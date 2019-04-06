//
//  OMDBModel.swift
//  OMDBClient
//
//  Created by Amandeep on 02/04/19.
//  Copyright © 2019 Amandeep. All rights reserved.
//

import Foundation

struct OMDBModel: Codable {
    var results: [Result]
    let totalResults, response: String
    
    enum CodingKeys: String, CodingKey {
        case results = "Search"
        case totalResults
        case response = "Response"
    }
    var totalCount: Int{
        return Int(totalResults) ?? 0
    }
    
}

struct Result: Codable {
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
    
    var formattedDate: String {
        let split = year.split(separator: "–")
        return calculateYearDifference(releasedYear: split)
    }
    

    
    private func calculateYearDifference(releasedYear: [String.SubSequence]) -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        dateFormatter.dateFormat = "MM/dd/yyyy"
        print(releasedYear)
     let yearDiff = releasedYear.map { subStringYear -> String in
            let stringYear = String(subStringYear)
            let releaseDate = dateFormatter.date(from: "01/01/\(stringYear)")
            let components = calendar.dateComponents([.year], from: releaseDate!, to: currentDate)
            let year = components.year!.description
            return year
        }
        
        let suffix = dateSuffix(string: yearDiff)
        let isCurrentYear = yearDiff.allSatisfy { $0 == "0"}
        let formattedDate = yearDiff.joined(separator: "-") + " " + suffix
        
        if isCurrentYear {
             return "This year"
        }
        else {
            return formattedDate
        }
       
 
        
    }
    
    private func dateSuffix(string:[String]) -> String {
        let intArray = string.compactMap{ Int($0)}
        let ma = max(intArray.first!, intArray.last!)
        switch ma {
        case 0:
            return "year ago"
        case 1:
            return "year ago"
        default:
            return "years ago"
        }
        
        
    }
    
  
}

enum TypeEnum: String, Codable {
    case game = "game"
    case movie = "movie"
    case series = "series"
    
   
}

