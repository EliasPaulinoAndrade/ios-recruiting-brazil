//
//  MovieViewModelWithFavoriteOptions.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 21/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

protocol MovieViewModelWithFavoriteOptions: MovieViewModel {
    var needUpdateFavorite: ((_ faved: Bool) -> Void)? { get set}
    var favoritesNavigator: MovieViewModelWithFavoriteOptionsNavigator? { get set }
    
    func usedTappedToFavoriteMovie()
}

extension MovieViewModel {
    var withFavoriteOptions: MovieViewModelWithFavoriteOptions? {
        return self as? MovieViewModelWithFavoriteOptions
    }
}

class DefaultMovieViewModelWithFavoriteOptions: MovieViewModelDecorator, MovieViewModelWithFavoriteOptions {
    weak var favoritesNavigator: MovieViewModelWithFavoriteOptionsNavigator?
    
    var needUpdateFavorite: ((Bool) -> Void)? {
        didSet {
            self.needUpdateFavorite?(self.isFaved ?? false)
        }
    }
    
    private var isFaved: Bool? {
        didSet {
            guard let isFaved = self.isFaved else {
                return
            }
            self.needUpdateFavorite?(isFaved)
        }
    }
    private let favoriteHandlerRepository: FavoriteMovieHandlerRepository
    
    init(favoriteHandlerRepository: FavoriteMovieHandlerRepository, decorated: MovieViewModelWithData) {
        self.favoriteHandlerRepository = favoriteHandlerRepository
        super.init(decorated)
        
        getFavoriteInformation()
    }
    
    func usedTappedToFavoriteMovie() {
        guard let isFaved = self.isFaved else {
            return
        }
        
        guard isFaved else {
            addToFavorites()
            return
        }
    
        removeFavorite()
    }
    
    private func getFavoriteInformation() {
        favoriteHandlerRepository.movieIsFavorite(movie) { [weak self] (result) in
            switch result {
            case .success(let isFaved):
                self?.isFaved = isFaved
            case .failure:
                self?.isFaved = false
            }
        }
    }
    
    private func addToFavorites() {
        favoriteHandlerRepository.addMovieToFavorite(movie) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.isFaved = true
                self.favoritesNavigator?.userFavedMovie(movie: self.movie)
            default:
                break
            }
        }
    }
    
    private func removeFavorite() {
        favoriteHandlerRepository.removeMovieFromFavorite(movieID: movie.id) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.isFaved = false
                self.favoritesNavigator?.userUnFavedMovie(movie: self.movie)
            default:
                break
            }
        }
    }
}
