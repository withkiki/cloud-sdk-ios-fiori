//
//  LineIndicatorView.swift
//  FioriCharts
//
//  Created by Xu, Sheng on 3/26/20.
//

import SwiftUI

struct LineIndicatorView: View {
    @ObservedObject var model: ChartModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.layoutDirection) var layoutDirection
    
    public init(_ model: ChartModel) {
        self.model = model
    }
    
    var body: some View {
        GeometryReader { proxy in
            self.makeBody(rect: proxy.frame(in: .local))
        }
    }
    
    func makeBody(rect: CGRect) -> some View {
        var selectedCategoryRange: ClosedRange<Int> = -1 ... -1
        var x: CGFloat = 0
        var yPosDict = [Int: CGFloat]()
        if let tmp = model.selectedCategoryInRange {
            selectedCategoryRange = tmp
        }
        
        let closestDataIndex = selectedCategoryRange.lowerBound
        let count = ChartUtility.numOfDataItems(model)
        let secondarySeriesIndexes = model.indexesOfSecondaryValueAxis.sorted()

        if closestDataIndex >= 0 && closestDataIndex < count {
            let width = rect.size.width
            let unitWidth: CGFloat = width * model.scale / CGFloat(max(count - 1, 1))
            let startIndex = Int((CGFloat(model.startPos) / unitWidth).rounded(.up))
            let startOffset: CGFloat = (unitWidth - CGFloat(model.startPos).truncatingRemainder(dividingBy: unitWidth)).truncatingRemainder(dividingBy: unitWidth)
            let displayRange = ChartUtility.displayRange(model)
            let seconaryDisplayRange = ChartUtility.displayRange(model, secondary: true)
            
            x = rect.origin.x + startOffset + CGFloat(closestDataIndex - startIndex) * unitWidth
            
            for i in 0 ..< model.data.count {
                let range = secondarySeriesIndexes.contains(i) ? seconaryDisplayRange : displayRange
                
                if let value = ChartUtility.dimensionValue(model, seriesIndex: i, categoryIndex: closestDataIndex) {
                    let y = rect.size.height - (CGFloat(value) - range.lowerBound) * rect.size.height / (range.upperBound - range.lowerBound) + rect.origin.y
                    yPosDict[i] = y
                }
            }
        }
        
        let seriesIndexes = Array(yPosDict.keys.sorted())
        
        return ZStack {
            if closestDataIndex >= 0 {
                LineShape(pos1: CGPoint(x: x, y: rect.origin.y),
                          pos2: CGPoint(x: x, y: rect.origin.y + rect.size.height),
                          layoutDirection: layoutDirection)
                    .stroke(Palette.hexColor(for: .primary2).color(colorScheme), lineWidth: 1)
                
                SelectionAnchorShape()
                    .rotation(Angle(degrees: 180))
                    .fill(Palette.hexColor(for: .primary2).color(colorScheme))
                    .frame(width: 9, height: 4)
                    .position(x: x, y: 2)
                
                SelectionAnchorShape()
                    .fill(Palette.hexColor(for: .primary2).color(colorScheme))
                    .frame(width: 9, height: 4)
                    .position(x: x, y: rect.origin.y + rect.size.height - 2)
                
                ForEach(seriesIndexes, id: \.self) { i in
                    ZStack {
                        Circle()
                            .fill(self.model.seriesAttributes[i].point.strokeColor.color(self.colorScheme))
                            .frame(width: self.model.seriesAttributes[i].point.diameter + 5.0,
                                   height: self.model.seriesAttributes[i].point.diameter + 5.0)
                            .position(CGPoint(x: x, y: yPosDict[i] ?? 0))
                        
                        Circle().stroke(Palette.hexColor(for: .primary6).color(self.colorScheme),
                                        style: StrokeStyle(lineWidth: 4))
                            .frame(width: self.model.seriesAttributes[i].point.diameter + 9.0,
                                   height: self.model.seriesAttributes[i].point.diameter + 9.0)
                            .position(CGPoint(x: x, y: yPosDict[i] ?? 0))
                    }
                }
            }
        }
    }
}

struct LineIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        LineIndicatorView(Tests.lineModels[0])
            .frame(width: 300, height: 200, alignment: .topLeading)
            .padding(32)
            .previewLayout(.sizeThatFits)
    }
}
