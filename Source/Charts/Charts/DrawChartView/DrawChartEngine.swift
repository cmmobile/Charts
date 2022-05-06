//
//  DrawEngine.swift
//  Charts
//
//  Created by cm0673 on 2022/4/27.
//

import Foundation

protocol DrawChartEngine {
    
    func set(drawDataSet: DrawChartDataSet)
    
    func draw(_ recognizer: NSUIPanGestureRecognizer)
    
    func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer)
    
}
