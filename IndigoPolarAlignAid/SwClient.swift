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
    
//    func getImageURL() -> String {
//        return "m101_pinwheel_galaxy-St"
//    }
    
    func getImageURL() -> String {
        return "file:/Users/greg/Library/Containers/GB.IndigoPolarAlignAid/Data/img_01.jpg"
    }
    
    func getCorrectionVector() -> CGVector {
        return correctionVector
    }
    
    init() {
        let myClientTask: Task = Task {
            let argc: CInt = 2
            var argv: [UnsafePointer<CChar>?] = [("IndigoPolarAlignAid" as NSString).utf8String,("2" as NSString).utf8String,nil]
            
            let isCancelled = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            isCancelled.initialize(to: Task.isCancelled)
            defer { isCancelled.deallocate() }

            await withTaskCancellationHandler {
                _ = myClient(argc, &argv, isCancelled)
            } onCancel: {
                isCancelled.pointee = true
            }
        }
        let _: Task = Task {
            try await Task.sleep(for: .seconds(10))
            print("Timesup!")
            myClientTask.cancel()
            print("SWClient: isCancelled is \(myClientTask.isCancelled)")
        }
    }
}
