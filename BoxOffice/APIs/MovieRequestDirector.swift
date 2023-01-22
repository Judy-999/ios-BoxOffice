//
//  MovieRequestDirector.swift
//  BoxOffice
//
//  Created by Judy on 2023/01/20.
//

import Foundation

struct MovieRequestDirector {
    private let builder: MovieRequestBuilder
    
    init(_ builder: MovieRequestBuilder = MovieRequestBuilder()) {
        self.builder = builder
    }
    
    func dailyBoxOfficeRequest(date: String, itemPerPage: String = "10") -> MovieRequest? {
        let dailyBoxOfficeRequest = builder.setBaseURL(.kobis)
            .setPath(.dailyBoxOffice)
            .setQuery(["key": Bundle.main.kobisApiKey,
                       "targetDt": date,
                       "wideAreaCd": "0105001",
                       "itemPerPage": itemPerPage])
            .buildRequest()

        return dailyBoxOfficeRequest
    }
    
    func weeklyBoxOfficeRequest(date: String,
                                      itemPerPage: String = "10",
                                      weekOption: WeekOption) -> MovieRequest? {
        let weeklyBoxOfficeRequest = builder.setBaseURL(.kobis)
            .setPath(.weeklyBoxOffice)
            .setQuery(["key": Bundle.main.kobisApiKey,
                       "targetDt": date,
                       "weekGb": weekOption.rawValue,
                       "wideAreaCd": "0105001",
                       "itemPerPage": itemPerPage])
            .buildRequest()
            
        return weeklyBoxOfficeRequest
    }
    
    func movieInfoRequest(movieCode: String) -> MovieRequest? {
        let movieInfoRequest = builder.setBaseURL(.kobis)
            .setPath(.movieInfo)
            .setQuery(["key": Bundle.main.kobisApiKey,
                       "movieCd": movieCode])
            .buildRequest()

        return movieInfoRequest
    }
    
    func moviePosterRequest(movieTitle: String, year: String? = nil) -> MovieRequest? {
        let moviePosterRequest: MovieRequest?
        
        if let year = year {
            moviePosterRequest = builder.setBaseURL(.omdb)
                .setPath(.empty)
                .setQuery(["apikey": Bundle.main.omdbApiKey,
                           "s": movieTitle,
                           "y": year])
                .buildRequest()
        } else {
            moviePosterRequest = builder.setBaseURL(.omdb)
                .setPath(.empty)
                .setQuery(["apikey": Bundle.main.omdbApiKey,
                          "s": movieTitle])
                .buildRequest()
        }
        
        return moviePosterRequest
    }
}
