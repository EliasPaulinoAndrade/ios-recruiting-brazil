//
//  MovieDetailView.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 21/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class MovieDetailView: UIView, ViewCodable {
    let viewModel: MovieViewModel

    private let scrollView = UIScrollView()
    let moviesListLayoutGuide = UILayoutGuide()
    private let scrollContentView = UIView().build {
        $0.backgroundColor = .clear
    }
    private lazy var headerView = MovieHeaderView().build {
        $0.favoriteButtonTapCompletion = { [weak self] in
            self?.viewModel.withFavoriteOptions?.usedTappedToFavoriteMovie()
        }
    }
    private let similarsLabel = UILabel(text: "Similar Movies").build {
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .appTextBlue
    }
    private let genresLabel = UILabel().build {
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .appTextBlue
    }
    private let overviewLabel = UILabel().build {
        $0.numberOfLines = 0
        $0.textColor = .appTextPurple
        $0.font = .systemFont(ofSize: 15)
    }
    private let bodyBackgroundView = UIView().build {
        $0.backgroundColor = .black
    }
    private let marginsLayoutGuide = UILayoutGuide()
    let movieImageView = UIImageView().build {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .appRed
    }
    
    private lazy var closeButton = RoundedImageView().build {
        $0.image = UIImage(named: "closeButton")
        $0.layer.build {
            $0.shadowOpacity = 0.5
            $0.shadowOffset = .zero
        }
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped)))
    }
    
    init(viewModel: MovieViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildHierarchy() {
        self.addSubViews(movieImageView, bodyBackgroundView, scrollView, closeButton)
        scrollView.addSubViews(scrollContentView)
        scrollContentView.addSubViews(headerView, genresLabel, overviewLabel, similarsLabel)
        scrollContentView.addLayoutGuide(marginsLayoutGuide)
        addLayoutGuide(moviesListLayoutGuide)
    }

    func addConstraints() {
        scrollView.layout.fillSuperView()
        scrollContentView.layout.group
            .centerX.top
            .width.bottom
            .fillToSuperView()
        marginsLayoutGuide.layout.fill(view: scrollContentView, margin: 10)
        headerView.layout.group.top(300).left.right.fill(to: marginsLayoutGuide)
        movieImageView.layout.build {
            $0.top.equal(to: layout.top).priority = .defaultLow
            $0.group.left.right.fillToSuperView()
            $0.bottom.equal(to: headerView.layout.centerY)
        }
        bodyBackgroundView.layout.build {
            $0.group.left.bottom.right.fillToSuperView()
            $0.top.equal(to: headerView.layout.centerY)
        }
        genresLabel.layout.build {
            $0.group.left.right.fill(to: marginsLayoutGuide)
            $0.top.equal(to: headerView.layout.bottom, offsetBy: 10)
        }
        overviewLabel.layout.build {
            $0.group.left.right.fill(to: marginsLayoutGuide)
            $0.top.equal(to: genresLabel.layout.bottom, offsetBy: 20)
        }
        closeButton.layout.build {
            $0.right.equalToSuperView(margin: -10)
            $0.bottom.lessThanOrEqual(to: headerView.layout.top, offsetBy: -10)
            $0.top.equal(to: safeAreaLayoutGuide.layout.top, offsetBy: 10).priority = .defaultLow
            $0.width.equal(to: 50)
            $0.height.equal(to: 50)
        }
        similarsLabel.layout.build {
            $0.group.left.right.fill(to: marginsLayoutGuide)
            $0.top.equal(to: overviewLabel.layout.bottom, offsetBy: 10)

        }
        moviesListLayoutGuide.layout.build {
            $0.top.equal(to: similarsLabel.layout.bottom)
            $0.group.left.bottom.right.fill(to: marginsLayoutGuide)
            $0.height.equal(to: 300)
        }
        
        overviewLabel.setContentHuggingPriority(.required, for: .vertical)
        overviewLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        movieImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        movieImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        bodyBackgroundView.setContentHuggingPriority(.defaultLow, for: .vertical)
        bodyBackgroundView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    func observeViewModel() {
        headerView.viewAtributtes = (title: viewModel.movieAtributtes.title, subTitle: viewModel.movieAtributtes.release)
        overviewLabel.text = viewModel.movieAtributtes.description
        viewModel.needReplaceImage = { [weak self] image in
            DispatchQueue.main.async {
                self?.movieImageView.image = image
            }
        }
        viewModel.needReplaceGenres = { [weak self] genres in
            DispatchQueue.main.async {
                self?.genresLabel.text = genres
            }
        }
        viewModel.withFavoriteOptions?.needUpdateFavorite = { [weak self] isFaved in
            DispatchQueue.main.async {
                self?.headerView.setFavoriteState(isFaved: isFaved)
            }
        }
    }
    
    @objc func closeButtonTapped() {
        viewModel.closeButtonWasTapped()
    }
}
