//
//  FavoriteViewModelsFactory.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 22/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

class FavoriteViewModelsFactory: DefaultViewModelFactory {
    override func movieListViewModel() -> MoviesListViewModel {
        return DefaultMoviesListViewModel(moviesRepository: FavoriteMoviesRepository(), presentations: [
            Presentation(hasFavorite: false),
            Presentation(hasFavorite: true)
        ]) { (injectorData) -> MovieViewModel in
            switch injectorData {
            case .favorite(let movie):
                return self.movieViewModelWithFavoriteOptions(movie: movie)
            case .normal(let movie):
                return self.movieViewModel(movie: movie)
            }
        }
    }
}
