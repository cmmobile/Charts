//
//  CMLineChart1ViewController.swift
//  CMDemo
//
//  Created by cm0673 on 2022/2/23.
//  Copyright © 2022 dcg. All rights reserved.
//

import UIKit
import Charts

class CMLineChart2ViewController: UIViewController {
    
    @IBOutlet weak var chartView: DrawChartView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var msgLabel: UILabel!
    
    let klineInfos = KlineData.demoArray
    
    var dataSets: [DrawChartDataSet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.isHidden = true
        cancelBtn.isHidden = true
        
        chartView.legend.enabled = false
        chartView.scaleYEnabled = false
        
        let renderer = CustomCombinedChartRenderer(chart: chartView, animator: chartView.chartAnimator, viewPortHandler: chartView.viewPortHandler)
        let drawRenderer = DrawChartRenderer(dataProvider: self, provider: chartView, viewPortHandler: chartView.viewPortHandler)
        renderer.otherFrontRenderers = [drawRenderer]
        chartView.renderer = renderer
        relaodChart()
    }
    
    func relaodChart() {
        let combineData = CombinedChartData()
        var entries: [CandleChartDataEntry] = []
        for (index, info) in klineInfos.enumerated() {
            let dataEntry = CandleChartDataEntry(x: Double(index), shadowH: info.h, shadowL: info.l, open: info.o, close: info.c)
            entries.append(dataEntry)
        }
        let candleConfig: CandleChartDataSet = .init(entries: entries, label: "Data Set")
        candleConfig.neutralColor = .white
        candleConfig.decreasingColor = .green
        candleConfig.decreasingFilled = true
        candleConfig.increasingColor = .red
        candleConfig.increasingFilled = true
        candleConfig.shadowColorSameAsCandle = true
        candleConfig.drawValuesEnabled = false
        
        combineData.candleData = CandleChartData(dataSet: candleConfig)
        chartView.data = combineData
        chartView.zoom(scaleX: 12, scaleY: 1, x: 720, y: 0)
    }
    
    @IBAction func randomAction(_ sender: Any) {
        var x = CGFloat(arc4random_uniform(100) + 650)
        var y = CGFloat(arc4random_uniform(500) + 200)
        let start: CGPoint = .init(x: x, y: y)
        x = CGFloat(arc4random_uniform(100) + 650)
        y = CGFloat(arc4random_uniform(500) + 200)
        let end: CGPoint = .init(x: x, y: y)
        dataSets.append(.init(start: start, end: end))
        chartView.notifyDataSetChanged()
    }
    
    @IBAction func startDrawAction(_ sender: Any) {
        saveBtn.isHidden = false
        cancelBtn.isHidden = false
        
        let portHandler = chartView.viewPortHandler!
        let gap = portHandler.contentWidth / 3
        var startX = portHandler.contentLeft + gap
        startX = chartView.getTransformer(forAxis: .left).valueForTouchPoint(x: startX, y: 0).x
        
        var endX = portHandler.contentLeft + gap * 2
        endX = chartView.getTransformer(forAxis: .left).valueForTouchPoint(x: endX, y: 0).x
        
        let sIndex = Int(startX)
        let eIndex = Int(endX)
        guard klineInfos.indices.contains(sIndex) && klineInfos.indices.contains(eIndex) else {return}
        let start: CGPoint = .init(x: Double(sIndex), y: klineInfos[sIndex].c)
        let end: CGPoint = .init(x: Double(eIndex), y: klineInfos[eIndex].c)
        chartView.set(drawDataSet: .init(start: start, end: end))
        chartView.startDraw()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let p0 = chartView.drawDataSet.startPoint
        let p1 = chartView.drawDataSet.endPoint
        chartView.closeDraw()
        saveBtn.isHidden = true
        cancelBtn.isHidden = true
        
        dataSets.append(.init(start: p0, end: p1))
        chartView.notifyDataSetChanged()
    }
    
    @IBAction func cacnelAction(_ sender: Any) {
        chartView.closeDraw()
        saveBtn.isHidden = true
        cancelBtn.isHidden = true
    }
    
}

extension CMLineChart2ViewController: DrawChartDataProvider {
    
    var drawData: DrawChartData {
        let data = DrawChartData(dataSets: dataSets)
        return data
    }
    
    
}
