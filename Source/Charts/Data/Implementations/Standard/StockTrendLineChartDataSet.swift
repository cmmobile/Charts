//
//  StockTrendLineChartDataSet.swift
//  Charts
//
//  Created by cm0673 on 2022/2/24.
//
//  https://github.com/cmmobile/Charts
//

import Foundation
import CoreGraphics

/// 股價走勢圖專用DataSet
public class StockTrendLineChartDataSet: LineChartDataSet {
    
    public var refPrice: CGFloat = 0
    public var valueUpColor: UIColor = .red
    public var valueDownColor: UIColor = .green
    public var refPriceColor: UIColor = .white
    public var valueUpFill: Fill?
    public var valueDownFill: Fill?
    
    public override init(entries: [ChartDataEntry]?, label: String?) {
        super.init(entries: entries, label: label)
        mode = .stockTrend
    }
    
    public required init() {
        super.init()
    }
    
    public func setupValueUpGradientFill(_ colors: [UIColor]) {
        let angle: CGFloat = 90
        let fillColors = colors.map { $0.cgColor }
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: fillColors as CFArray, locations: nil) else {return}
        valueUpFill = Fill(linearGradient: gradient, angle: angle)
    }
    
    public func setupValueDownGradientFill(_ colors: [UIColor]) {
        let angle: CGFloat = 90
        let fillColors = colors.map { $0.cgColor }
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: fillColors as CFArray, locations: nil) else {return}
        valueDownFill = Fill(linearGradient: gradient, angle: angle)
    }
    
}
