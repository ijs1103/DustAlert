//
//  customNavBarAppearance.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/02.
//

import UIKit

@available(iOS 13.0, *)
func customNavBarAppearance() -> UINavigationBarAppearance {
    let customNavBarAppearance = UINavigationBarAppearance()
    // Apply a transparent background.
    customNavBarAppearance.configureWithTransparentBackground()
    
    // Apply white colored normal and large titles.
    customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: Const.Color.navBarLargeTitle]

    // Apply white color to all the nav bar buttons.
    let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
    barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.lightText]
    barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.label]
    barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white]
    customNavBarAppearance.buttonAppearance = barButtonItemAppearance
    customNavBarAppearance.backButtonAppearance = barButtonItemAppearance
    customNavBarAppearance.doneButtonAppearance = barButtonItemAppearance
    
    return customNavBarAppearance
}
