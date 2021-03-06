//
//  GenresRepository.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 21/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

protocol GenresRepository {
    func getAllGenres(completion: @escaping (Result<[Genre], Error>) -> Void)
}
