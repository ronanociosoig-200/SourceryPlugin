//
//  HomeViewController.swift
//  Pokedex
//
//  Created by Ronan on 09/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

import UIKit

public class HomeViewController: UIViewController {
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var backpackButton: UIButton!
    
    var presenter: HomePresenting?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func ballButtonAction() {
        guard let presenter = presenter else { return }
        presenter.ballButtonAction()
    }
    
    @IBAction func backpackButtonAction() {
        guard let presenter = presenter else { return }
        presenter.backpackButtonAction()
    }
}

extension HomeViewController: HomeView {
    
}
