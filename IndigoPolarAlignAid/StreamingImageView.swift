//
//  StreamingImageView.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-03.
//

import SwiftUI

struct StreamingImageView: View {
    var body: some View {
        let swClient = SwClient()
        GeometryReader { geometry in
            Image(swClient.getImageURL())
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
            
//            AsyncImage(url: URL(string: "file:///Users/greg/Documents/GitHub/IndigoPolarAlignAid/IndigoPolarAlignAid/Assets.xcassets/m101_pinwheel_galaxy-St.imageset/m101_pinwheel_galaxy-St.png"))
        }
    }
}

struct StreamingImageView_Previews: PreviewProvider {
    static var previews: some View {
        StreamingImageView()
    }
}
