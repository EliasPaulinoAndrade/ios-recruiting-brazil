//
//  MoviesListViewModelNavigator.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 21/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

protocol MoviesListViewModelNavigator: AnyObject {
    func movieWasSelected(movie: Movie)
    func movieWasFaved(movie: Movie)
    func movieWasUnfaved(movie: Movie)
}
