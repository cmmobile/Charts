//
//  DrawChartView.swift
//  Charts
//
//  Created by cm0673 on 2022/3/11.
//

import Foundation
import CoreGraphics
import UIKit

open class DrawChartView: CombinedChartView {
    
    public private(set) var drawDataSet: DrawChartDataSet = .init(start: .zero, end: .zero)
    
    public private(set) var drawMode: Mode = .none
    var drawBoard: DrawLineBoard = .init()
    
    private var drawEngine: DrawChartEngine?
    
    open override func initialize() {
        super.initialize()
        doubleTapToZoomEnabled = false
        scaleYEnabled = false
        
        addSubview(drawBoard)
        drawBoard.backgroundColor = .clear
        drawBoard.isUserInteractionEnabled = false
        drawBoard.translatesAutoresizingMaskIntoConstraints = false
        getFillUpConstraint(subView: drawBoard, superView: self)
            .forEach {$0.isActive = true}
    }
    
    open override func notifyDataSetChanged() {
        super.notifyDataSetChanged()
        if drawMode == .drawing {
            set(drawDataSet: drawDataSet)
        }
    }
    
    public func set(drawDataSet: DrawChartDataSet) {
        self.drawDataSet = drawDataSet
        switch drawDataSet.drawType {
        case .straight:
            self.drawEngine = DrawLineEngine(chart: self)
        case .horizontal:
            self.drawEngine = DrawHorizontalLineEngine(chart: self)
        }
        guard let drawEngine = drawEngine else {return}
        drawEngine.set(drawDataSet: drawDataSet)
    }
    
    open func drawHighlight(valuePoint: CGPoint) {
        //  給子類別override
    }
    
    open func tapPoint(point: CGPoint) {
        //  給子類別override
    }
    
    open func update(mode: Mode) {
        drawMode = mode
        switch mode {
        case .drawing:
            scaleXEnabled = false
        case .none:
            scaleXEnabled = true
            drawClear()
        }
    }
    
    private func drawClear() {
        drawBoard.points.0 = .zero
        drawBoard.points.1 = .zero
        drawBoard.isDrawing = false
        drawBoard.setNeedsDisplay()
    }
    
    open override func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        switch drawMode {
        case .none:
            super.tapGestureRecognized(recognizer)
        case .drawing:
            drawEngine?.tapGestureRecognized(recognizer)
        }
        tapPoint(point: point)
    }
    
    override func panGestureRecognized(_ recognizer: NSUIPanGestureRecognizer) {
        switch drawMode {
        case .none:
            super.panGestureRecognized(recognizer)
        case .drawing:
            draw(recognizer: recognizer)
        }
    }
    
    open func draw(recognizer: NSUIPanGestureRecognizer) {
        drawEngine?.draw(recognizer)
    }
    
    // MARK: - Tool
    
    private func getFillUpConstraint(subView: UIView, superView: UIView) -> [NSLayoutConstraint] {
        let constraints = [
            NSLayoutConstraint(item: subView, attribute: .bottom, relatedBy: .equal, toItem: superView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: subView, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: subView, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1, constant: 0)
        ]
        return constraints
    }
    
    public enum Mode {
        case drawing
        case none
    }
    
}

class DrawLineBoard: UIView {
    
    var isDrawing = false
    var points: (CGPoint, CGPoint) = (.zero, .zero)
    var lineWidth: CGFloat = 1
    var lineColor: UIColor = .white
    var highlightPoint: CGPoint = .zero
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard isDrawing == true else {return}
        guard let context = UIGraphicsGetCurrentContext() else {return}
        let pointArray = [points.0, points.1]
        context.saveGState()
        context.setLineWidth(lineWidth)
        context.setLineCap(.butt)
        context.setStrokeColor(lineColor.cgColor)
        context.strokeLineSegments(between: pointArray)
        
        var circleRadius: CGFloat
        var circleDiameter: CGFloat
        circleRadius = 7
        circleDiameter = circleRadius * 2.0
        let point = highlightPoint
        var rect: CGRect = .zero
        rect.origin.x = point.x - circleRadius
        rect.origin.y = point.y - circleRadius
        rect.size.width = circleDiameter
        rect.size.height = circleDiameter
        let color = lineColor.withAlphaComponent(0.6)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rect)
        
        circleRadius = 3
        circleDiameter = circleRadius * 2.0
        for point in pointArray {
            var rect: CGRect = .zero
            rect.origin.x = point.x - circleRadius
            rect.origin.y = point.y - circleRadius
            rect.size.width = circleDiameter
            rect.size.height = circleDiameter
            context.setFillColor(lineColor.cgColor)
            context.fillEllipse(in: rect)
        }
        
        context.restoreGState()
    }
    
}
