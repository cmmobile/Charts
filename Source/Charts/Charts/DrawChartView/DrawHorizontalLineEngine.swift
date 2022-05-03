//
//  DrawHorizontalLineEngine.swift
//  Charts
//
//  Created by cm0673 on 2022/4/27.
//

import Foundation
import CoreGraphics
import UIKit

class DrawHorizontalLineEngine: DrawChartEngine {
    
    private var touchOriginPoint: CGPoint = .zero
    var drawValuePoint: CGPoint = .zero
    var drawValue2Point: CGPoint = .zero
    weak var chart: DrawChartView?
    
    init(chart: DrawChartView?) {
        self.chart = chart
    }
    
    func set(drawDataSet: DrawChartDataSet) {
        guard let chart = chart else {return}
        drawValuePoint = drawDataSet.startPoint
        drawValue2Point = drawDataSet.endPoint
        let drawBoard = chart.drawBoard
        let trans = chart.getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        drawBoard.points.0 = drawDataSet.startPoint.applying(valueToPixelMatrix)
        drawBoard.highlightPoint = drawValuePoint.applying(valueToPixelMatrix)
        drawBoard.points.1 = drawDataSet.endPoint.applying(valueToPixelMatrix)
        drawBoard.lineWidth = drawDataSet.lineWidth
        drawBoard.lineColor = drawDataSet.color
        drawBoard.isDrawing = true
        drawBoard.setNeedsDisplay()
        chart.drawHighlight(valuePoint: drawDataSet.startPoint)
    }
    
    func draw(_ recognizer: NSUIPanGestureRecognizer) {
        guard let chart = chart else {return}
        let trans = chart.getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        let pixelToValueMatrix = trans.pixelToValueMatrix
        let point = recognizer.location(in: chart)
        let drawBoard = chart.drawBoard
        switch recognizer.state {
        case .began:
            touchOriginPoint = point
        case .changed:
            let diffX = touchOriginPoint.x - point.x
            let diffY = touchOriginPoint.y - point.y
            let diffPt: CGPoint = .init(x: diffX, y: diffY)
            let diffValuePt: CGPoint = .init(x: pixelToValueMatrix.a * diffPt.x, y: pixelToValueMatrix.d * diffPt.y)
            var x = drawValuePoint.x - diffValuePt.x
            if x > (chart.highestVisibleX - 0.5) {
                x = (chart.highestVisibleX - 0.5)
            }
            if x < (chart.lowestVisibleX + 0.5) {
                x = (chart.lowestVisibleX + 0.5)
            }
            x = round(x)
            let y = drawValuePoint.y - diffValuePt.y
            let newPoint: CGPoint = .init(x: x, y: y)
            let newPoint2: CGPoint = .init(x: round(drawValue2Point.x), y: newPoint.y)
            chart.drawHighlight(valuePoint: newPoint)
            drawBoard.points.0 = newPoint.applying(valueToPixelMatrix)
            drawBoard.highlightPoint = newPoint.applying(valueToPixelMatrix)
            drawBoard.points.1 = newPoint2.applying(valueToPixelMatrix)
            drawBoard.setNeedsDisplay()
        case .ended, .cancelled:
            let diffX = touchOriginPoint.x - point.x
            let diffY = touchOriginPoint.y - point.y
            let diffPt: CGPoint = .init(x: diffX, y: diffY)
            let diffValuePt: CGPoint = .init(x: pixelToValueMatrix.a * diffPt.x, y: pixelToValueMatrix.d * diffPt.y)
            var x = drawValuePoint.x - diffValuePt.x
            if x > (chart.highestVisibleX - 0.5) {
                x = (chart.highestVisibleX - 0.5)
            }
            if x < (chart.lowestVisibleX + 0.5) {
                x = (chart.lowestVisibleX + 0.5)
            }
            x = round(x)
            let y = drawValuePoint.y - diffValuePt.y
            let newPoint: CGPoint = .init(x: x, y: y)
            let newPoint2: CGPoint = .init(x: round(drawValue2Point.x), y: newPoint.y)
            drawBoard.points.0 = newPoint.applying(valueToPixelMatrix)
            drawBoard.highlightPoint = newPoint.applying(valueToPixelMatrix)
            drawBoard.points.1 = newPoint2.applying(valueToPixelMatrix)
            drawBoard.setNeedsDisplay()
            
            drawValuePoint = newPoint
            drawValue2Point = newPoint2
            chart.drawHighlight(valuePoint: newPoint)
            chart.drawDataSet.startPoint = drawValuePoint
            chart.drawDataSet.endPoint = drawValue2Point
        default:
            break
        }
    }
    
    func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer) {
        guard let chart = chart else {return}
        let point = recognizer.location(in: chart)
        setAnchorPoint(touchPoint: point)
        chart.drawHighlight(valuePoint: drawValuePoint)
    }
    
    private func setAnchorPoint(touchPoint: CGPoint) {
        guard let chart = chart else {return}
        let drawBoard = chart.drawBoard
        let trans = chart.getTransformer(forAxis: .left)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        let p0 = drawValuePoint.applying(valueToPixelMatrix)
        let p1 = drawValue2Point.applying(valueToPixelMatrix)
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
            swap(&drawValuePoint, &drawValue2Point)
        } else {
            let distance0 = yDistance(p0, touchPoint)
            let distance1 = yDistance(p1, touchPoint)
            if distance0 < distance1 {
            } else {
                swap(&drawValuePoint, &drawValue2Point)
            }
        }
        drawBoard.highlightPoint = drawValuePoint.applying(valueToPixelMatrix)
        drawBoard.setNeedsDisplay()
    }
    
}
