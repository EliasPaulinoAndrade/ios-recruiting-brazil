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
    let moviesCollectionLayout = UICollectionViewFlowLayout()
    
    weak var delegate: MoviesListViewDelegate?
    
    lazy var moviesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: moviesCollectionLayout).build {
        $0.registerReusableCell(forCellType: MinimizedMovieCollectionCell.self)
        $0.dataSource = self
        $0.delegate = self
    }
    
    init(viewModel: MoviesListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildHierarchy() {
        addSubViews(moviesCollectionView)
    }
    
    func addConstraints() {
        moviesCollectionView.layout.fillSuperView()
    }
    
    func observeViewModel() {
        viewModel.needShowNewMovies = { [weak self] newMoviesRange in
            DispatchQueue.main.async {
                self?.moviesCollectionView.insertItemsInRange(newMoviesRange)
            }
        }
        
        viewModel.needShowError = { [weak self] errorMessage in
            self?.delegate?.needShowError(withMessage: errorMessage) {
                self?.viewModel.thePageReachedTheEnd()
            }
        }
        
        viewModel.thePageReachedTheEnd()
    }
}

extension MoviesListView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCell = moviesCollectionView.dequeueReusableCell(
            forCellType: MinimizedMovieCollectionCell.self,
            for: indexPath
        )
        
        movieCell.viewModel = viewModel.viewModelFromMovie(atPosition: indexPath.row)
        
        return movieCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let movieCellWidth = (collectionView.frame.width - 3 * moviesCollectionLayout.minimumInteritemSpacing)/3
        return CGSize(width: movieCellWidth, height: movieCellWidth * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfMovies - 1 {
            viewModel.thePageReachedTheEnd()
        }
    }
}

