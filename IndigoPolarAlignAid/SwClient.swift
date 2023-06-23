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
}

//func myClientCall() {
//    let argc: CInt = 2
//    let argv  = ["arg 1", "arg 2"]
//    print("\(argc)\n\(argv)")
//    //var myClientResult = myClient(mySwiftArgc, mySwiftArgv)
//}
//
//func swiftClient(argc: Int32, argv: UnsafeMutablePointer<UnsafePointer<CChar>?>?) -> Int32? {
//    myClient(argc, argv)
//    return Int32(0)
//}
