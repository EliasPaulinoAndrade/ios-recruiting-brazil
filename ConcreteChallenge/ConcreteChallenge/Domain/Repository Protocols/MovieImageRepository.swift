//
//  MovieImageRepository.swift
//  ConcreteChallenge
//
//  Created by Elias Paulino on 21/12/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

typealias CancellCompletion = () -> Void

protocol MovieImageRepository {
    
    func getImage(withPath path: String, completion: @escaping ((Result<URL, Error>) -> Void)) -> CancellCompletion
}
