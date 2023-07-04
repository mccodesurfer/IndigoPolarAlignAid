//
//  StreamingImageView.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-03.
//

import SwiftUI

struct StreamingImageView: View {
    var body: some View {
        let swClient: SwClient = SwClient.sharedInstance
        GeometryReader { geometry in
//            Image(swClient.imageURL.path)
//                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
            
            AsyncImage(url: swClient.imageURL)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
    }
}

struct StreamingImageView_Previews: PreviewProvider {
    static var previews: some View {
        StreamingImageView()
    }
}
