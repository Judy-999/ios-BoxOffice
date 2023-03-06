//
//  DailyBoxOfficeRepository.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/05.
//

import UIKit
import RxSwift

struct BoxOfficeRepository {
    func requestDailyData(with date: String) -> Observable<BoxOfficeDTO> {
        let searchDailyBoxOfficeListAPI = DailyBoxOfficeListAPI(date: date)
        let result = searchDailyBoxOfficeListAPI.execute()
        let dailyBoxOfficeList = result.compactMap {
            $0.boxOfficeResult.dailyBoxOfficeList
        }.flatMap {
            Observable.from($0)
        }
        
        return dailyBoxOfficeList
    }
    
    func requestAllWeekData(with date: String) -> Observable<BoxOfficeDTO> {
        let searchWeeklyBoxOfficeListAPI = WeeklyBoxOfficeListAPI(date: date,
                                                                  weekOption: .allWeek)
        let result = searchWeeklyBoxOfficeListAPI.execute()
        let weeklyBoxOfficeList = result.compactMap {
            $0.boxOfficeResult.weeklyBoxOfficeList
        }.flatMap {
            Observable.from($0)
        }
        
        return weeklyBoxOfficeList
    }
    
    func requestWeekEndData(with date: String) -> Observable<BoxOfficeDTO> {
        let searchWeeklyBoxOfficeListAPI = WeeklyBoxOfficeListAPI(date: date,
                                                                  weekOption: .weekEnd)
        let result = searchWeeklyBoxOfficeListAPI.execute()
        let weeklyBoxOfficeList = result.compactMap {
            $0.boxOfficeResult.weeklyBoxOfficeList
        }.flatMap {
            Observable.from($0)
        }
        
        return weeklyBoxOfficeList
    }
    
    func fetchMovieDetailInfo(_ list: Observable<BoxOfficeDTO>) -> Observable<MovieInfo> {
        let movieInfoList = list.concatMap { boxOffice in
            MovieInfoAPI(movieCode: boxOffice.movieCd).execute()
                .compactMap { movieInfoResponseDTO in
                    movieInfoResponseDTO.movieInfoResult.movieInfo
                }
        }
        
        return movieInfoList
    }
    
    func task(list: Observable<BoxOfficeDTO>,
                      movieInfoList: Observable<MovieInfo>,
                      posterList: Observable<UIImage?>) -> Observable<[MovieData]> {
        let movieDatas = Observable.zip(list, movieInfoList, posterList) {
            boxOffice, movieInfo, image in
            let movie = toMovie(with: boxOffice, movieInfo, image)
            return movie
        }
            .take(10)
            .toArray()
        
        return movieDatas.asObservable()
    }
}

extension BoxOfficeRepository {
    private func toMovie(with boxOffice: BoxOfficeDTO,
                         _ movieInfo: MovieInfo,
                         _ image: UIImage?) -> MovieData {
        return MovieData(
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
}
