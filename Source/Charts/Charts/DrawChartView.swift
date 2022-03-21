//
//  DrawChartView.swift
//  Charts
//
//  Created by cm0673 on 2022/3/11.
//

import Foundation
import CoreGraphics

open class DrawChartView: CombinedChartView {
    
    public private(set) var drawDataSet: DrawChartDataSet = .init(start: .zero, end: .zero)
    
    private var drawMode: Mode = .none
    private var touchOriginValuePoint: CGPoint = .zero
    private var touchOriginPoint: CGPoint = .zero
    private var drawBoard: DrawLineBoard = .init()
    
    private var drawValuePoint: CGPoint = .zero
    private var anchorValuePoint: CGPoint = .zero
    
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
    
    public func set(drawDataSet: DrawChartDataSet) {
        self.drawDataSet = drawDataSet
        let trans = getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        drawValuePoint = drawDataSet.startPoint
        anchorValuePoint = drawDataSet.endPoint
        drawBoard.points.0 = drawDataSet.startPoint.applying(valueToPixelMatrix)
        drawBoard.highlightPoint = drawValuePoint.applying(valueToPixelMatrix)
        drawBoard.points.1 = drawDataSet.endPoint.applying(valueToPixelMatrix)
        drawBoard.isDrawing = true
        drawBoard.setNeedsDisplay()
        drawHighlight(valuePoint: drawDataSet.startPoint)
    }
    
    public func startDraw() {
        update(mode: .drawing)
        drawMode = .drawing
    }
    
    public func closeDraw() {
        update(mode: .none)
        drawMode = .none
        drawClear()
    }
    
    open func drawHighlight(valuePoint: CGPoint) {
        //  給子類別override
    }
    
    open func update(mode: Mode) {
        drawMode = mode
        switch mode {
        case .drawing:
            scaleXEnabled = false
        case .none:
            scaleXEnabled = true
        }
    }
    
    private func drawClear() {
        drawBoard.points.0 = .zero
        drawBoard.points.1 = .zero
        drawBoard.isDrawing = false
        drawBoard.setNeedsDisplay()
    }
    
    override func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer) {
        switch drawMode {
        case .none:
            super.tapGestureRecognized(recognizer)
        case .drawing:
            let point = recognizer.location(in: self)
            setAnchorPoint(touchPoint: point)
            drawHighlight(valuePoint: drawValuePoint)
        }
    }
    
    override func panGestureRecognized(_ recognizer: NSUIPanGestureRecognizer) {
        switch drawMode {
        case .none:
            super.panGestureRecognized(recognizer)
        case .drawing:
            draw(recognizer)
        }
    }
    
    private func draw(_ recognizer: NSUIPanGestureRecognizer) {
        let trans = getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        switch recognizer.state {
        case .began:
            let point = recognizer.location(in: self)
            touchOriginValuePoint = trans.valueForTouchPoint(point)
            touchOriginPoint = point
        case .changed:
            let point = recognizer.location(in: self)
            let valuePoint = trans.valueForTouchPoint(point)
            let diffX = touchOriginValuePoint.x - valuePoint.x
            let diffY = touchOriginValuePoint.y - valuePoint.y
            let x = drawValuePoint.x - diffX
            let newPoint: CGPoint = .init(x: round(x), y: drawValuePoint.y - diffY)
            drawHighlight(valuePoint: newPoint)
            drawBoard.points.0 = newPoint.applying(valueToPixelMatrix)
            drawBoard.highlightPoint = newPoint.applying(valueToPixelMatrix)
            drawBoard.points.1 = anchorValuePoint.applying(valueToPixelMatrix)
            drawBoard.setNeedsDisplay()
        case .ended, .cancelled:
            let point = recognizer.location(in: self)
            let valuePoint = trans.valueForTouchPoint(point)
            let diffX = touchOriginValuePoint.x - valuePoint.x
            let diffY = touchOriginValuePoint.y - valuePoint.y
            let x = drawValuePoint.x - diffX
            let newPoint: CGPoint = .init(x: round(x), y: drawValuePoint.y - diffY)
            drawBoard.points.0 = newPoint.applying(valueToPixelMatrix)
            drawBoard.highlightPoint = newPoint.applying(valueToPixelMatrix)
            drawBoard.points.1 = anchorValuePoint.applying(valueToPixelMatrix)
            drawBoard.setNeedsDisplay()
            
            drawValuePoint = newPoint
            drawHighlight(valuePoint: newPoint)
            drawDataSet.startPoint = drawValuePoint
            drawDataSet.endPoint = anchorValuePoint
        default:
            break
        }
    }
    
    // MARK: - Tool
    
    private func toValuePoint(_ pixelPoint: CGPoint) -> CGPoint {
        let trans = getTransformer(forAxis: .left)
        let pixelToValueMatrix = trans.pixelToValueMatrix
        return pixelPoint.applying(pixelToValueMatrix)
    }
    
    private func setAnchorPoint(touchPoint: CGPoint) {
        let trans = getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        let p0 = drawValuePoint.applying(valueToPixelMatrix)
        let p1 = anchorValuePoint.applying(valueToPixelMatrix)
        func xDistance(_ p: CGPoint, _ rP: CGPoint) -> CGFloat {
            return abs(p.x - rP.x)
        }
        func yDistance(_ p: CGPoint, _ rP: CGPoint) -> CGFloat {
            return abs(p.y - rP.y)
        }
        let distance0 = xDistance(p0, touchPoint)
        let distance1 = xDistance(p1, touchPoint)
        if distance0 < distance1 {
        } else if distance0 > distance1 {
            swap(&drawValuePoint, &anchorValuePoint)
        } else {
            let distance0 = yDistance(p0, touchPoint)
            let distance1 = yDistance(p1, touchPoint)
            if distance0 < distance1 {
            } else {
                swap(&drawValuePoint, &anchorValuePoint)
            }
        }
        drawBoard.highlightPoint = drawValuePoint.applying(valueToPixelMatrix)
        drawBoard.setNeedsDisplay()
    }
    
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
    var highlightPoint: CGPoint = .zero
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard isDrawing == true else {return}
        guard let context = UIGraphicsGetCurrentContext() else {return}
        let lineColor = UIColor.white
        let pointArray = [points.0, points.1]
        context.saveGState()
        context.setLineWidth(2)
        context.setLineCap(.butt)
        context.setStrokeColor(UIColor.white.cgColor)
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
