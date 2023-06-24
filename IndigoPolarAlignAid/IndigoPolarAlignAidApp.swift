//
//  IndigoPolarAlignAidApp.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-05-20.
//

import SwiftUI

@main
struct IndigoPolarAlignAidApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init(){
        let swClient = SwClient()
        swClient.runMyClient()
    }
}
