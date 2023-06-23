//
//  ContentView.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-05-20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ZStack {
                StreamingImageView()
                OverlayView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
