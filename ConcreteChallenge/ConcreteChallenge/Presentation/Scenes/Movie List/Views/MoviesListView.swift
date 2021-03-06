//
//  MoviesListView.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 19/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class MoviesListView: UIView, ViewCodable {
    let viewModel: MoviesListViewModel
    weak var delegate: MoviesListViewDelegate?
    var presentationManager: MovieListPresentationManager
    
    var scrollDirection: UICollectionView.ScrollDirection {
        get {
            return self.moviesCollectionLayout.scrollDirection
        } set {
            self.moviesCollectionLayout.scrollDirection = newValue
        }
    }
    
    private let moviesCollectionLayout = UICollectionViewFlowLayout()
    private lazy var moviesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: moviesCollectionLayout).build {
        self.presentationManager.registerCells(atMoviesCollectionView: $0)
        $0.dataSource = self
        $0.delegate = self
        $0.contentInset.top = 50
    }
    
    private lazy var emptyWarningLabel = UILabel(text: viewModel.emptyStateDescription).build {
        $0.textColor = .appTextPurple
        $0.font = .systemFont(ofSize: 15)
        $0.numberOfLines = 0
    }
    
    /// the toggle button is initilized with the presentation manager data.
    private lazy var toggleButton = ToggleButton(items: presentationManager.toggleButtonItems).build {
        $0.wasToggledCompletion = { [weak self] currentSelection in
            self?.viewModel.viewStateChanged(toState: currentSelection)
        }
    }
    
    private let loadingIndicatorView = RoundedActivityIndicatorView()
    
    init(viewModel: MoviesListViewModel, presentationManager: MovieListPresentationManager) {
        self.viewModel = viewModel
        self.presentationManager = presentationManager
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildHierarchy() {
        addSubViews(moviesCollectionView, toggleButton, emptyWarningLabel, loadingIndicatorView)
    }
    
    func addConstraints() {
        loadingIndicatorView.layout.fillSuperView()
        emptyWarningLabel.layout.group.left(10).top(10).right(-10).fill(to: safeAreaLayoutGuide)
        moviesCollectionView.layout.fillSuperView()
        toggleButton.layout.build {
            $0.group.top(5).right(-5).fillToSuperView()
            $0.height.equal(to: 40)
        }
    }
    
    func observeViewModel() {
        viewModel.needShowNewMovies = { [weak self] newMoviesRange in
            DispatchQueue.main.async {
                self?.moviesCollectionView.insertItemsInRange(newMoviesRange)
            }
        }
        
        viewModel.needShowError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.delegate?.needShowError(withMessage: errorMessage) {
                    self?.viewModel.thePageReachedTheEnd()
                }
            }
        }
        
        viewModel.needReloadAllMovies = { [weak self] in
            DispatchQueue.main.async {
                self?.moviesCollectionView.reloadData()
            }
        }
        
        viewModel.needReloadMovieView = { [weak self] moviePosition in
            DispatchQueue.main.async {
                self?.findMovieCell(atPosition: moviePosition) { (movieView) in
                    movieView.viewModel = self?.viewModel.viewModelFromMovie(atPosition: moviePosition)
                }

                self?.moviesCollectionView.reloadItems(at: [IndexPath(item: moviePosition, section: 0)])
            }
        }
        
        viewModel.needDeleteMovieView = { [weak self] moviePosition in
            DispatchQueue.main.async {
                let movieIndexPath = IndexPath(row: moviePosition, section: 0)
                self?.moviesCollectionView.deleteItems(at: [movieIndexPath])
            }
        }
        
        viewModel.needInsertMovieView = { [weak self] moviePosition in
            DispatchQueue.main.async {
                let movieIndexPath = IndexPath(row: moviePosition, section: 0)
                self?.moviesCollectionView.insertItems(at: [movieIndexPath])
            }
        }
        
        viewModel.needChangeEmptyStateVisibility = { [weak self] visible in
            DispatchQueue.main.async {
                self?.moviesCollectionView.isHidden = visible
                self?.toggleButton.isHidden = visible
                self?.emptyWarningLabel.isHidden = !visible
            }
        }
        
        viewModel.needChangeLoadingStateVisibility = { [weak self] visible in
            DispatchQueue.main.async {
                if visible {
                    self?.loadingIndicatorView.startLoading()
                } else {
                    self?.loadingIndicatorView.stopLoading()
                }
            }
        }
        
        viewModel.thePageReachedTheEnd()
    }
    
    private func findMovieCell(atPosition position: Int, completion: (MovieView) -> Void) {
        let movieIndexPath = IndexPath(row: position, section: 0)
        guard let movieView = self.moviesCollectionView.cellForItem(at: movieIndexPath) as? MovieView else {
            return
        }
        
        completion(movieView)
    }
    
    func viewForMovieAt(position: Int) -> UIView? {
        return moviesCollectionView.cellForItem(at: IndexPath.init(row: position, section: 0))
    }
}

extension MoviesListView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCell = presentationManager.dequeueCell(
            fromCollection: collectionView,
            indexPath: indexPath,
            presentationMode: viewModel.currentPresentation
        )
        
        movieCell.viewModel = viewModel.viewModelFromMovie(atPosition: indexPath.row)
           
        return movieCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return presentationManager.sizeForCell(
            presentationMode: viewModel.currentPresentation,
            atCollectionView: collectionView) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfMovies - 2 {
            viewModel.thePageReachedTheEnd()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.userSelectedMovie(atPosition: indexPath.row)
    }
    
    struct PresentationMode {
        var cellType: MovieViewCell.Type
        var iconImage: UIImage?
        var numberOfColumns: Int
        var heightFactor: CGFloat
    }
}
