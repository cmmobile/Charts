//
//  DrawChartView.swift
//  Charts
//
//  Created by cm0673 on 2022/3/11.
//

import Foundation
import CoreGraphics

open class DrawChartView: CombinedChartView {
    
    public private(set) var valuePoints: (CGPoint, CGPoint) = (.zero, .zero)
    
    private(set) var inDrawMode = false
    private var touchOriginValuePoint: CGPoint = .zero
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
    
    public func drawClear() {
        drawBoard.points.0 = .zero
        drawBoard.points.1 = .zero
        drawBoard.setNeedsDisplay()
    }
    
    public func set(lPoint: CGPoint, rPoint: CGPoint) {
        valuePoints = (lPoint, rPoint)
        
        let trans = getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        drawBoard.points.0 = lPoint.applying(valueToPixelMatrix)
        drawBoard.points.1 = rPoint.applying(valueToPixelMatrix)
        drawBoard.setNeedsDisplay()
    }
    
    public func set(inDrawMode: Bool) {
        self.inDrawMode = inDrawMode
        if inDrawMode == true {
            scaleXEnabled = false
        } else {
            scaleXEnabled = true
        }
    }
    
    override func panGestureRecognized(_ recognizer: NSUIPanGestureRecognizer) {
        if inDrawMode == true {
            draw(recognizer)
        } else {
            super.panGestureRecognized(recognizer)
        }
    }
    
    private func draw(_ recognizer: NSUIPanGestureRecognizer) {
        let trans = getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        switch recognizer.state {
        case .began:
            let point = recognizer.location(in: self)
            touchOriginValuePoint = trans.valueForTouchPoint(point)
            setAnchorPoint(x: touchOriginValuePoint.x, y: touchOriginValuePoint.y)
        case .changed:
            let point = recognizer.location(in: self)
            let valuePoint = trans.valueForTouchPoint(point)
            let diffX = touchOriginValuePoint.x - valuePoint.x
            let diffY = touchOriginValuePoint.y - valuePoint.y
            let x = drawValuePoint.x - diffX
            
            let newPoint: CGPoint = .init(x: round(x), y: drawValuePoint.y - diffY)
            drawBoard.points.0 = newPoint.applying(valueToPixelMatrix)
            drawBoard.points.1 = anchorValuePoint.applying(valueToPixelMatrix)
            drawBoard.setNeedsDisplay()
        case .ended, .cancelled:
            let point = recognizer.location(in: self)
            let valuePoint = trans.valueForTouchPoint(point)
            let diffX = touchOriginValuePoint.x - valuePoint.x
            let diffY = touchOriginValuePoint.y - valuePoint.y
            let x = drawValuePoint.x - diffX
            drawValuePoint = .init(x: round(x), y: drawValuePoint.y - diffY)
            valuePoints = (drawValuePoint, anchorValuePoint)
        default:
            break
        }
    }
    
    // MARK: - Tool
    
    private func setAnchorPoint(x: CGFloat, y: CGFloat) {
        let distance0 = abs(valuePoints.0.x - x)
        let distance1 = abs(valuePoints.1.x - x)
        if distance0 < distance1 {
            drawValuePoint = valuePoints.0
            anchorValuePoint = valuePoints.1
        } else {
            drawValuePoint = valuePoints.1
            anchorValuePoint = valuePoints.0
        }
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
    
}

class DrawLineBoard: UIView {
    
    var points: (CGPoint, CGPoint) = (.zero, .zero)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {return}
        context.saveGState()
        context.setLineWidth(2)
        context.setLineCap(.butt)
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokeLineSegments(between: [points.0, points.1])
        context.restoreGState()
    }
    
}
