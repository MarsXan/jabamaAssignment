//
//  CustomMarkerView.swift
//  Jabama
//
//  Created by Mohsen on 12/2/24.
//

import SwiftUI

struct CustomMarkerView: View {
    var score:Double
    var body: some View {
        MarkerShape()
            .fill(LinearGradient(
                gradient: Gradient(colors: [.kAccent, .purple]),
                startPoint: .top,
                endPoint: .bottom)
            )
            .frame(width: 50, height: 60)
            .shadow(radius: 5)
            .overlay(alignment:.top){
                Text("\(score.removeZerosFromEnd())".prefix(3))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.top,12)
                
            }
    }
}

#Preview {
    CustomMarkerView(score:7.6)
}

struct MarkerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let circleCenter = CGPoint(x: width / 2, y: width / 2)
        let circleRadius = width / 2
        path.addEllipse(in: CGRect(x: 0, y: 0, width: width, height: width))
        path.move(to: CGPoint(x: circleCenter.x - circleRadius / 2, y: circleCenter.y))
        path.addLine(to: CGPoint(x: circleCenter.x + circleRadius / 2, y: circleCenter.y))
        path.addLine(to: CGPoint(x: circleCenter.x, y: height))
        path.closeSubpath()
        
        return path
    }
}