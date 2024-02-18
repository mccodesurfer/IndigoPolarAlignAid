//
//  OverlayView.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-03.
//

import SwiftUI

struct OverlayView: View {
    @State private var selectedLocation: CGPoint?
    @State private var correctionVector: CGVector?
    var body: some View {
        let swClient: SwClient = SwClient()
        GeometryReader { geometry in
            Canvas { context, size in
                context.stroke(
                    Path(CGRect(origin: .zero, size: geometry.size)),
                    with: .color(.green),
                    lineWidth: 0)
            }
            
            if let selectedLocation = selectedLocation {
                Path() { path in
                    path.move(to: selectedLocation)
                    path.addLine(to: CGPoint(x: selectedLocation.x + swClient.correctionVector.dx, y: selectedLocation.y + swClient.correctionVector.dy))}.stroke(lineWidth: 2)
                Path(ellipseIn: CGRect(origin: CGPoint(x: selectedLocation.x + swClient.correctionVector.dx - swClient.targetRadius, y: selectedLocation.y + swClient.correctionVector.dy - swClient.targetRadius), size: CGSize(width: swClient.targetRadius*2, height: swClient.targetRadius*2))).stroke(lineWidth: 2)
            }
        }
        .onTapGesture(coordinateSpace: .local) { location in
            print("Tap location: \(location)")
            selectedLocation = location
            correctionVector = swClient.correctionVector
        }
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView()
    }
}
