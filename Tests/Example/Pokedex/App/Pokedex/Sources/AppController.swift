//
//  AppController.swift
//  Pokedex
//
//  Created by Ronan on 09/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

import Foundation
import Common

protocol AppControlling {
    func start()
}

class AppController: AppControlling {
    var coordinator: Coordinating?
    
    func start() {
        coordinator = Coordinator()
        coordinator?.start()
    }
}
