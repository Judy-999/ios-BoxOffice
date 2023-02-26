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
        let movieInfoList = list.concatMap { boxOffice in
            fetchMovieDetailInfo(with: boxOffice.movieCd)
        }

        let posterList = movieInfoList.concatMap { movieInfo in
            fetchMoviePosterURL(with: movieInfo.movieNmEn,
                                year: String(movieInfo.prdtYear.prefix(4)))
        }.concatMap { posterURL in
            if let url = posterURL {
                return imageCacheManager.getImage(with: URL(string: url))
            }
            
            return Observable<UIImage?>.just(BoxOfficeImage.posterPlacehorder)
        }.catchAndReturn(BoxOfficeImage.posterPlacehorder)
            
        
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
                genreName: movieInfo.genres.first?.genreNm ?? "정보없음",
                directorName: movieInfo.directors.first?.peopleNm ?? "정보없음",
                actors: movieInfo.actors.map { $0.peopleNm },
                ageLimit: movieInfo.audits.first?.watchGradeNm ?? "X"
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
            .catchAndReturn(nil)
    }
}
    }
}
