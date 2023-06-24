//
//  myApp.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-01.
//

import Foundation

struct SwClient {
    static let sharedInstance = SwClient() // so all view use the same instance
    
    let targetRadius = 10.0
    var correctionVector = CGVector(dx: 50.0, dy: 50.0)
    
    func getImageURL() -> String {
        return "m101_pinwheel_galaxy-St"
    }
    
    func getCorrectionVector() -> CGVector {
        return correctionVector
    }
    
    func runMyClient() {
        let argc: CInt = 2
        var argv: [UnsafePointer<CChar>?] = [("IndigoPolarAlignAid" as NSString).utf8String,("2" as NSString).utf8String,nil]
                
        print("\(argc)\n\(argv)")
        var myClientResult = myClient(argc, &argv)
    }
}
