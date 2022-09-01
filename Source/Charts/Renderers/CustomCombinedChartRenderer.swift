//
//  CustomCombinedChartRenderer.swift
//  Charts
//
//  Created by cm0673 on 2022/3/11.
//

import Foundation

/// 可抽換CombinedChartRenderer裡面的子renderer
public class CustomCombinedChartRenderer: CombinedChartRenderer {
    
    private var renderPresenterDic: [CombinedChartView.DrawOrder: () -> DataRenderer?] = [:]
    
    public var otherBackRenderers: [DataRenderer] = []
    public var otherFrontRenderers: [DataRenderer] = []
    /// 強制使用客製化CreateRenderers
    public var customCreateRenderer: (() -> ([DataRenderer]?))?
    
    public func swap(type: CombinedChartView.DrawOrder, renderer: @escaping () -> DataRenderer?) {
        renderPresenterDic[type] = renderer
    }
    
    public override func createRenderers() {
        if let customCreate = customCreateRenderer, let renderers = customCreate() {
            _renderers = renderers
            return
        }
        guard let chart = chart else { return }
        var renderers: [DataRenderer] = otherBackRenderers
        
        for order in drawOrder
        {
            if let swapRenderClosure = renderPresenterDic[order],
                let swapRender = swapRenderClosure() {
                renderers.append(swapRender)
                continue
            }
            switch (order)
            {
            case .bar:
                if chart.barData !== nil
                {
                    renderers.append(BarChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
            case .line:
                if chart.lineData !== nil
                {
                    renderers.append(LineChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
            case .candle:
                if chart.candleData !== nil
                {
                    renderers.append(CandleStickChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
            case .scatter:
                if chart.scatterData !== nil
                {
                    renderers.append(ScatterChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
            case .bubble:
                if chart.bubbleData !== nil
                {
                    renderers.append(BubbleChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
            }
        }
        otherFrontRenderers.forEach {
            renderers.append($0)
        }
        _renderers = renderers
    }
}
