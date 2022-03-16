//
//  DrawChartRenderer.swift
//  Charts
//
//  Created by cm0673 on 2022/3/11.
//

import Foundation

public class DrawChartRenderer: BarLineScatterCandleBubbleRenderer {
    
    private weak var provider: BarLineScatterCandleBubbleChartDataProvider?
    private weak var dataProvider: DrawChartDataProvider?
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    public init(dataProvider: DrawChartDataProvider, provider: BarLineScatterCandleBubbleChartDataProvider, viewPortHandler: ViewPortHandler) {
        self.provider = provider
        self.dataProvider = dataProvider
        super.init(animator: Animator(), viewPortHandler: viewPortHandler)
    }
    
    public
    override func drawData(context: CGContext) {
        guard let dataProvider = dataProvider else {return}
        let data = dataProvider.drawData
        for set in data.dataSets {
            draw(context: context, set)
        }
    }
    
    private func draw(context: CGContext, _ dataSet: DrawChartDataSet) {
        guard let provider = provider else {return}
        context.saveGState()
        context.setLineWidth(dataSet.lineWidth)
        context.setLineCap(.butt)
        
        let trans = provider.getTransformer(forAxis: dataSet.axisDependency)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let pointsPerEntryPair = 2
        if _lineSegments.count != pointsPerEntryPair {
            _lineSegments = [CGPoint](repeating: CGPoint(), count: pointsPerEntryPair)
        }
        _lineSegments[0] = dataSet.startPoint
        _lineSegments[1] = dataSet.endPoint
        
        for i in 0..<_lineSegments.count {
            _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
        }
        
        context.setStrokeColor(dataSet.color.cgColor)
        context.strokeLineSegments(between: _lineSegments)
        
        context.restoreGState()
    }
    
    public
    override func drawValues(context: CGContext) {
    }
    
    public
    override func drawExtras(context: CGContext) {
    }
    
    public
    override func drawHighlighted(context: CGContext, indices: [Highlight]) {
    }
    
}

public protocol DrawChartDataProvider: AnyObject {
    var drawData: DrawChartData { get }
    
}

open class DrawChartData {
    
    var dataSets: [DrawChartDataSet]
    
    public init(dataSets: [DrawChartDataSet]) {
        self.dataSets = dataSets
    }
    
}

open class DrawChartDataSet: CustomStringConvertible {
    
    var startPoint: CGPoint
    var endPoint: CGPoint
    
    public var lineWidth: CGFloat = 1
    var axisDependency: YAxis.AxisDependency = .left
    var color: UIColor = .white
    
    public var description: String {
        "start: \(startPoint) end: \(endPoint)"
    }
    
    public init (start: CGPoint, end: CGPoint) {
        startPoint = start
        endPoint = end
    }
    
    enum DrawType {
        case straight
    }
    
}
