//
//  MoviePosterDTO.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/05.
//

struct MoviePosterDTO: Decodable {
    let search: [MovieDTO]
    let totalResults: String
    let response: String
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
    
    var posterURL: String? {
        guard let posterURL = search.first?.poster else { return nil }
        
        return posterURL.count < 10 ? nil : posterURL
    }
}

struct MovieDTO: Decodable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
}
