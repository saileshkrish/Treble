//
//  SceneDelegate.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-09.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = PlayerViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
