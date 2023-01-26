//
//  SceneDelegate.swift
//  EventViewer
//
//  Created by Ilya Kharlamov on 1/26/23.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let eventManager: EventManager
    var window: UIWindow?
    
    override init() {
        self.eventManager = EventManager()
        super.init()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(
            rootViewController: EventsListViewController(eventManager: self.eventManager)
        )
        self.window = window
        window.makeKeyAndVisible()
    }
    
}
