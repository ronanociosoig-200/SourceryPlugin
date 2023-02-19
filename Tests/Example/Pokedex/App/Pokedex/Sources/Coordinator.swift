//
//  Coordinator.swift
//  Pokedex
//
//  Created by Ronan on 09/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

import Foundation
import Common
import Home
import UIKit

class Coordinator: Coordinating {
    let window: UIWindow
    lazy var actions = Actions(coordinator: self)
    var currentViewController: UIViewController?
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
    }
    
    func start() {
        
        showHomeScene()
    }
    
    func showHomeScene() {
        let viewController = HomeWireframe.makeViewController()
        HomeWireframe.prepare(viewController, actions: actions as HomeActions)
        
        window.rootViewController = viewController
    }
    
    func showCatchScene(identifier: Int?) {
        
    }
    
    func searchNextPokemon() {
        
    }
    
    func showBackpackScene() {
        
    }
    
    func showPokemonDetailScene(pokemon: LocalPokemon) {
        
    }
    
    func showLoading() {
        
    }

    func dismissLoading() {

    }
    
    func showAlert(with message: String) {
        
    }
}
