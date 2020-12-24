//
//  MainTabBarController.swift
//  ClinicNotes
//
//  Created by Blezin on 14.12.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    

    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clinicVC = storyBoard.instantiateViewController(withIdentifier: "ClinicViewController") as! ClinicViewController
        let recentVC = storyBoard.instantiateViewController(withIdentifier: "RecentsViewController") as! RecentsViewController
      
        viewControllers = [
            generateNavigationController(rootViewController: clinicVC, title: "Clinic", image: UIImage(systemName: "table")!, selectedImage: UIImage(systemName: "table.fill")!),
            generateNavigationController(rootViewController: recentVC, title: "Recents", image: UIImage(systemName: "clock")!, selectedImage: UIImage(systemName: "clock.fill")!)
            
        ]
    }
    
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage, selectedImage: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.selectedImage = selectedImage
        return navigationVC
    }

}
