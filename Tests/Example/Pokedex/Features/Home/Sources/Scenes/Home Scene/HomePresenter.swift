//
//  HomePresenter.swift
//  Pokedex
//
//  Created by Ronan on 09/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

/// sourcery: AutoMockable
public protocol HomeView: AnyObject {
    
}

/// sourcery: AutoMockable
public protocol HomePresenting: AnyObject {
    func ballButtonAction()
    func backpackButtonAction()
}

public class HomePresenter: HomePresenting {
    
    // MARK: Properties
    
    private weak var view: HomeView?
    private var actions: HomeActions
    
    
    // MARK: Typealias
    
    typealias Actions = HomeActions
    
    typealias View = HomeView
    
    required init(view: HomeView, actions: HomeActions) {
        self.view = view
        self.actions = actions
    }
    
    public func ballButtonAction() {
        actions.ballButtonAction()
    }
    
    public func backpackButtonAction() {
        actions.backpackButtonAction()
    }
}
