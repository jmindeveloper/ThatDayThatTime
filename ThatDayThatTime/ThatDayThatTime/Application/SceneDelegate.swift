//
//  SceneDelegate.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private func configureNavigation() {
        UINavigationBar.appearance().barTintColor = .viewBackgroundColor
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = .darkGray
    }
    
    private func createTimeDiaryViewController() -> UINavigationController {
        let coreDataManager = CoreDataManager()
        let timeDiaryViewModel = TimeDiaryViewModel(coreDataManager: coreDataManager)
        
        return  UINavigationController(rootViewController: TimeDiaryViewController(viewModel: timeDiaryViewModel))
    }
    
    private func createPasswordViewController() -> UIViewController {
        let viewModel = ApplicationPasswordViewModel(passwordEntryStatus: .run)
        let vc = ApplicationPasswordViewController(viewModel: viewModel)
        
        return vc
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        configureNavigation()
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let securityState = UserSettingManager.shared.getSecurityState()
        
        if securityState {
            window?.rootViewController = createPasswordViewController()
        } else {
            window?.rootViewController = createTimeDiaryViewController()
        }
        
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

