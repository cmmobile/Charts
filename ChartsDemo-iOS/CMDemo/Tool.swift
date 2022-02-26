//
//  Tool.swift
//  CMDemo
//
//  Created by cm0673 on 2022/2/23.
//  Copyright © 2022 dcg. All rights reserved.
//

import UIKit

// 紀錄Storyboard的資訊
protocol StoryboardInstantiable {
    static var StoryboardName: String { get }
    static var StoryboardBundle: Bundle? { get }
    static var StoryboardIdentifier: String? { get }
}

extension UIViewController: StoryboardInstantiable {}

// 可直接產生Storyboard+Class之後的結果
extension StoryboardInstantiable {
    static var StoryboardName: String { return String(describing: self) }
    static var StoryboardIdentifier: String? { return String(describing: self) }
    static var StoryboardBundle: Bundle? { return Bundle(for: MyClass.self) }
    
    static func build() -> Self {
        let storyboard = UIStoryboard(name: StoryboardName, bundle: StoryboardBundle)
        if let storyboardIdentifier = StoryboardIdentifier {
            return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
        } else {
            return storyboard.instantiateInitialViewController() as! Self
        }
    }
}

fileprivate class MyClass {
    
}
