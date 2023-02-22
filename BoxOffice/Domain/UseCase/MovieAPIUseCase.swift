//
//  MovieAPIUseCase.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/05.
//

import Foundation

struct MovieAPIUseCase {
    private let imageCacheManager = URLCacheManager()
    
    func requestDailyData(with date: String,
                          in dataList: Observable<[MovieData]>) async throws {
        let searchDailyBoxOfficeListAPI = SearchDailyBoxOfficeListAPI(
            date: date
        )
        let result = try await searchDailyBoxOfficeListAPI.execute()
        let dailyBoxOfficeList = result?.boxOfficeResult.dailyBoxOfficeList ?? []
        
        
        task(dailyBoxOfficeList, dataList: dataList)
    }
    
    func requestAllWeekData(with date: String,
                            in dataList: Observable<[MovieData]>) async throws {
        let searchWeeklyBoxOfficeListAPI = SearchWeeklyBoxOfficeListAPI(
            date: date,
            weekOption: .allWeek
        )
        let result = try await searchWeeklyBoxOfficeListAPI.execute()
        let weeklyBoxOfficeList = result?.boxOfficeResult.weeklyBoxOfficeList ?? []

        task(weeklyBoxOfficeList, dataList: dataList)
    }
    
    func requestWeekEndData(with date: String, in dataList: Observable<[MovieData]>) async throws {
        let searchWeeklyBoxOfficeListAPI = SearchWeeklyBoxOfficeListAPI(
            date: date,
            weekOption: .weekEnd
        )
        let result = try await searchWeeklyBoxOfficeListAPI.execute()
        let weeklyBoxOfficeList = result?.boxOfficeResult.weeklyBoxOfficeList ?? []
        
        task(weeklyBoxOfficeList, dataList: dataList)
    }
    
    private func task(_ list: [BoxOffice], dataList: Observable<[MovieData]>) {
        dataList.value = []
        
        for boxOffice in list {
            Task {
                guard let movieInfo = try await fetchMovieDetailInfo(with: boxOffice.movieCd) else { return }
                let movieEnglishName = movieInfo.movieNmEn
                let movieOpenYear = String(movieInfo.prdtYear.prefix(4))
                
                do {
                    let posterURL = try await fetchMoviePosterURL(with: movieEnglishName,
                                                                  year: movieOpenYear)
                    try await appendCellData(
                        to: dataList,
                        boxOffice: boxOffice,
                        movieInfo: movieInfo,
                        posterURL: URL(string: posterURL ?? "")
                    )
                } catch {
                    try await appendCellData(
                        to: dataList,
                        boxOffice: boxOffice,
                        movieInfo: movieInfo,
                        posterURL: nil
                    )
                }
            }
        }
    }

    private func fetchMovieDetailInfo(with movieCode: String) async throws -> MovieInfo? {
        let searchMovieInfoAPI = SearchMovieInfoAPI(movieCode: movieCode)
        let result = try await searchMovieInfoAPI.execute()
        guard let movieInfo = result?.movieInfoResult.movieInfo else { return nil }
        return movieInfo
    }
    
    private func fetchMoviePosterURL(with movieName: String, year: String?) async throws -> String? {
        let searchMoviePosterAPI = SearchMoviePosterAPI(movieTitle: movieName, year: year)
        guard let result = try await searchMoviePosterAPI.execute() else { return nil }
        guard let url = result.posterURLString() else { return nil }
        return url
    }
    
    private func appendCellData(to list: Observable<[MovieData]>,
                                boxOffice: BoxOffice,
                                movieInfo: MovieInfo,
                                posterURL: URL?) async throws {
        let image = try await imageCacheManager.getImage(with: posterURL)
        
        list.value.append(
            MovieData(
                uuid: UUID(),
                poster: image,
                currentRank: boxOffice.rank,
                title: boxOffice.movieNm,
                openDate: movieInfo.openDt,
                totalAudience: boxOffice.audiAcc,
                rankChange: boxOffice.rankInten,
                isNewEntry: boxOffice.rankOldAndNew == "NEW",
                productionYear: movieInfo.prdtYear,
                openYear: String(movieInfo.openDt.prefix(4)),
                showTime: movieInfo.showTm,
                genreName: movieInfo.genres.count > 0 ? movieInfo.genres[0].genreNm : "",
                directorName: movieInfo.directors.count > 0 ? movieInfo.directors[0].peopleNm : "",
                actors: movieInfo.actors.count > 0 ? movieInfo.actors.map { $0.peopleNm } : [] ,
                ageLimit: movieInfo.audits.count > 0 ? movieInfo.audits[0].watchGradeNm : ""
            )
        )
    }
}
