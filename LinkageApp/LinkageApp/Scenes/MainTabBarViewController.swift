//
//  MainTabBarViewController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/10/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import CoreLocation

final class MainTabBarViewController: UITabBarController {
    
    // MARK: - Properties
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Method
    private func configView() {
        navigationController?.isNavigationBarHidden = false
    }
}

// MARK: - StoryboardSceneBased
extension MainTabBarViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}
