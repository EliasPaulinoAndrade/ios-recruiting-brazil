//
//  MinimizedMovieCollectionCell.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 19/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class MinimizedMovieCollectionCell: UICollectionViewCell, ViewCodable {
    let movieImageView = UIImageView().build {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .appRed
        $0.layer.cornerRadius = 5
    }
    
    let movieLabel = UILabel().build {
        $0.text = "bla"
        $0.textColor = .appTextBlue
        $0.font = .boldSystemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildHierarchy() {
        self.addSubViews(movieImageView, movieLabel)
    }

    func addConstraints() {
        movieImageView.layout.group
            .top
            .left
            .right.fillToSuperView()
        
        movieLabel.layout.build {
            $0.top.equal(to: movieImageView.layout.bottom)
            $0.group.bottom.left.right.fillToSuperView()
        }
    }
    
    func applyAditionalChanges() {
       
    }
}