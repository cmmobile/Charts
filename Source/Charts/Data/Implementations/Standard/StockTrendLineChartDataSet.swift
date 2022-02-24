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
    
    public override init(entries: [ChartDataEntry]?, label: String?) {
        super.init(entries: entries, label: label)
        mode = .stockTrend
    }
    
    public required init() {
        super.init()
    }
    
}
