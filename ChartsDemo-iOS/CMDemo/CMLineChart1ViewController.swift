//
//  CMLineChart1ViewController.swift
//  CMDemo
//
//  Created by cm0673 on 2022/2/23.
//  Copyright © 2022 dcg. All rights reserved.
//

import UIKit
import Charts

class CMLineChart1ViewController: UIViewController {
    
    @IBOutlet weak var chartView: CombinedChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.legend.enabled = false
        chartView.animate(xAxisDuration: 3, yAxisDuration: 0)
        
        let dataSet = getDataSet()
        let lineData = LineChartData(dataSet: dataSet)
        let combineData = CombinedChartData()
        combineData.lineData = lineData
        chartView.data = combineData
    }
    
    func getDataSet() -> LineChartDataSet {
        let count = 30
        let range: UInt32 = 5
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(range) + 300)
            return ChartDataEntry(x: Double(i), y: val, icon: #imageLiteral(resourceName: "icon"))
        }
        
        let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
        set1.drawIconsEnabled = false
        set1.lineWidth = 1
        set1.setColor(.red)
        set1.highlightColor = .white
        set1.highlightLineWidth = 1
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
//        set1.drawFilledEnabled = true
//        set1.fillAlpha = 0.2
        set1.mode = .stockTrend
        return set1
    }
    
}
