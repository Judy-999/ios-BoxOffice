//
//  DailyBoxOfficeUseCase.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/06.
//

import RxSwift

struct DailyBoxOfficeUseCase {
    private let movieRepository: BoxOfficeRepository
    private let posterRepository: PosterRepository
    
    init(_ movieRepository: BoxOfficeRepository,
         _ posterRepository: PosterRepository) {
        self.movieRepository = movieRepository
        self.posterRepository = posterRepository
    }
    
    func execute(date: String) -> Observable<[MovieData]> {
        let list = movieRepository.requestDailyData(with: date)
        let movieInfoList = movieRepository.fetchMovieDetailInfo(list)
        let posterList = posterRepository.fetchPoster(with: movieInfoList)
        
        let movies = movieRepository.task(list: list,
                                          movieInfoList: movieInfoList,
                                          posterList: posterList)
    
        return movies
    }
}
