//
//  MovieViewModelDecorator.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 21/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class MovieViewModelDecorator: MovieViewModelWithData {
    var navigator: MovieViewModelNavigator? {
        get {
            return decoratedMovieViewModel.navigator
        } set {
            decoratedMovieViewModel.navigator = newValue
        }
    }
    
    var movie: Movie {
        return decoratedMovieViewModel.movie
    }
    
    var movieAtributtes: (title: String, description: String, release: String) {
        return decoratedMovieViewModel.movieAtributtes
    }
    
    var needReplaceImage: ((UIImage) -> Void)? {
        set {
            decoratedMovieViewModel.needReplaceImage = newValue
        } get {
            return decoratedMovieViewModel.needReplaceImage
        }
    }
    
    var needReplaceGenres: ((String) -> Void)? {
        set {
            decoratedMovieViewModel.needReplaceGenres = newValue
        } get {
            return decoratedMovieViewModel.needReplaceGenres
        }
    }
    
    private var decoratedMovieViewModel: MovieViewModelWithData
    
    init(_ decorated: MovieViewModelWithData) {
        self.decoratedMovieViewModel = decorated
    }
    
    func movieViewWasReused() {
        decoratedMovieViewModel.movieViewWasReused()
    }
    
    func closeButtonWasTapped() {
        self.decoratedMovieViewModel.closeButtonWasTapped()
    }
}
