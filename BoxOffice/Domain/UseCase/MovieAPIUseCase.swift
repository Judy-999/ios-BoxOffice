//
//  MovieAPIUseCase.swift
//  BoxOffice
//
//  Created by 이원빈 on 2023/01/05.
//

import UIKit
import RxSwift

struct MovieAPIUseCase {
    private let imageCacheManager = URLCacheManager()
    
    func requestDailyData(with date: String) -> Observable<[MovieData]> {
        let searchDailyBoxOfficeListAPI = DailyBoxOfficeListAPI(date: date)
        let result = searchDailyBoxOfficeListAPI.execute()
        let dailyBoxOfficeList = result.compactMap {
            $0.boxOfficeResult.dailyBoxOfficeList
        }.flatMap {
            Observable.from($0)
        }

        return task(dailyBoxOfficeList)
    }
    
    func requestAllWeekData(with date: String) -> Observable<[MovieData]> {
        let searchWeeklyBoxOfficeListAPI = WeeklyBoxOfficeListAPI(date: date,
                                                                        weekOption: .allWeek)
        let result = searchWeeklyBoxOfficeListAPI.execute()
        let weeklyBoxOfficeList = result.compactMap {
            $0.boxOfficeResult.weeklyBoxOfficeList
        }.flatMap {
            Observable.from($0)
        }

        return task(weeklyBoxOfficeList)
    }
    
    func requestWeekEndData(with date: String) -> Observable<[MovieData]> {
        let searchWeeklyBoxOfficeListAPI = WeeklyBoxOfficeListAPI(date: date,
                                                                        weekOption: .weekEnd)
        let result = searchWeeklyBoxOfficeListAPI.execute()
        let weeklyBoxOfficeList = result.compactMap {
            $0.boxOfficeResult.weeklyBoxOfficeList
        }.flatMap {
            Observable.from($0)
        }
        
        return task(weeklyBoxOfficeList)
    }
    
    private func task(_ list: Observable<BoxOfficeDTO>) -> Observable<[MovieData]> {
        let movieInfoList = list.flatMap { boxOffice in
            fetchMovieDetailInfo(with: boxOffice.movieCd)
        }
        
        let posterList = movieInfoList.flatMap { movieInfo in
            fetchMoviePosterURL(with: movieInfo.movieNmEn,
                                year: String(movieInfo.prdtYear.prefix(4)))
        }.flatMap { posterURL in
            if let url = posterURL {
                return imageCacheManager.getImage(with: URL(string: url))
            }
            
            return Observable<UIImage?>.just(nil)
        }
        
        let movieDatas = Observable.zip(list, movieInfoList, posterList) { boxOffice, movieInfo, image in
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
        }
        .take(10)
        .toArray()
        
        return movieDatas.asObservable()
    }

    private func fetchMovieDetailInfo(with movieCode: String) -> Observable<MovieInfoDTO> {
        let searchMovieInfoAPI = MovieInfoAPI(movieCode: movieCode)
        
        return searchMovieInfoAPI.execute()
            .compactMap { movieInfoResponseDTO in
                movieInfoResponseDTO.movieInfoResult.movieInfo
            }
    }
    
    private func fetchMoviePosterURL(with movieName: String, year: String?) -> Observable<String?> {
        let searchMoviePosterAPI = MoviePosterAPI(movieTitle: movieName, year: year)
        
        return searchMoviePosterAPI.execute()
            .map { $0.posterURL }
    }
}
