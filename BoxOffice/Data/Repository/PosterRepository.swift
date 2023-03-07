//
//  PosterRepository.swift
//  BoxOffice
//
//  Created by 김주영 on 2023/03/06.
//

import UIKit
import RxSwift

struct PosterRepository {
    private let imageCacheManager: URLCacheManager
    
    init(imageCacheManager: URLCacheManager = .shared) {
        self.imageCacheManager = imageCacheManager
    }
    
    func fetchPoster(with movieInfoList: Observable<MovieInfo>) -> Observable<UIImage?> {
        let posterList = movieInfoList.concatMap { movieInfo in
            fetchMoviePosterURL(with: movieInfo.movieNmEn,
                                year: String(movieInfo.prdtYear.prefix(4)))
        }.concatMap { posterURL in
            if let url = posterURL {
                return imageCacheManager.getImage(with: URL(string: url))
            }
            
            return Observable<UIImage?>.just(BoxOfficeImage.posterPlacehorder)
        }.catchAndReturn(BoxOfficeImage.posterPlacehorder)
        
        return posterList
    }
    
    private func fetchMoviePosterURL(with movieName: String, year: String?) -> Observable<String?> {
        let searchMoviePosterAPI = MoviePosterAPI(movieTitle: movieName, year: year)
        
        return searchMoviePosterAPI.execute()
            .map { $0.posterURL }
            .catchAndReturn(nil)
    }
}
