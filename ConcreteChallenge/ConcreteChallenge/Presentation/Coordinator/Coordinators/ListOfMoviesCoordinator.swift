//
//  ListOfMoviesCoordinator.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 21/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

typealias ListOfMoviesCoordinatorAtributtes = (navigationTitle: String, tabbarAttributtes: TabbarAttributtes)
typealias UserFavedMovieEvent = (_ movie: Movie) -> Void

class ListOfMoviesCoordinator: Coordinator, MoviesListViewModelNavigator {
    var rootViewController: RootViewController
    
    var userFavedMovieCompletion: UserFavedMovieEvent?
    var userUnFavedMovieCompletion: UserFavedMovieEvent?
    
    lazy var moviesListViewController: MoviesListViewController = {
        let viewModel = self.viewModelsFactory.movieListViewModel(moviesRepository: nil, emptyStateTitle: nil)
        viewModel.navigator = self
        
        let moviesListViewController = MoviesListViewController(viewModel: viewModel, presentationManager: moviesListPresentationManager)
        return moviesListViewController
    }()
    
    var movieDetailCoordinator: MovieDetailCoordinator? {
        didSet {
            movieDetailCoordinator?.userFavedMovieCompletion = { [weak self] movie in
                self?.moviesListViewController.viewModel.reloadMovie(movie)
                self?.userFavedMovieCompletion?(movie)
            }
            
            movieDetailCoordinator?.userUnFavedMovieCompletion = { [weak self] movie in
                self?.moviesListViewController.viewModel.reloadMovie(movie)
                self?.userUnFavedMovieCompletion?(movie)
            }
        }
    }
    private var viewModelsFactory: ViewModelsFactory
    private let atributtes: ListOfMoviesCoordinatorAtributtes
    private let moviesListPresentationManager: MovieListPresentationManager
    
    init(rootViewController: RootViewController, viewModelsFactory: ViewModelsFactory, atributtes: ListOfMoviesCoordinatorAtributtes, moviesListPresentationManager: MovieListPresentationManager) {
        self.rootViewController = rootViewController
        self.viewModelsFactory = viewModelsFactory
        self.atributtes = atributtes
        self.moviesListPresentationManager = moviesListPresentationManager
    }
    
    func start(previousController: UIViewController? = nil) {
        rootViewController.add(viewController: moviesListViewController)
        
        moviesListViewController.title = atributtes.navigationTitle
        
        rootViewController.tabBarItem = UITabBarItem(tabbarAttributtes: atributtes.tabbarAttributtes)
        rootViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
    }
    
    func movieChangedInOtherScene(movie: Movie) {
        self.moviesListViewController.viewModel.reloadMovie(movie)
    }
    
    func movieWasAddedInOtherScene(movie: Movie) {
        self.moviesListViewController.viewModel.insertMovie(movie)
    }
    
    func movieRemovedInOtherScene(movie: Movie) {
        self.moviesListViewController.viewModel.deleteMovie(movie)
    }
    
    func movieWasSelected(movie: Movie) {
        movieDetailCoordinator = MovieDetailCoordinator(
            rootViewController: rootViewController,
            movie: movie,
            viewModelsFactory: self.viewModelsFactory
        )
        movieDetailCoordinator?.start(previousController: moviesListViewController)
    }
    
    func movieWasFaved(movie: Movie) {
        self.userFavedMovieCompletion?(movie)
    }

    func movieWasUnfaved(movie: Movie) {
        self.userUnFavedMovieCompletion?(movie)
    }
}
