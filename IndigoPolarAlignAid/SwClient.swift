//
//  myApp.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-01.
//

import Foundation

class SwClient {
    static let sharedInstance = SwClient() // so all view use the same instance
    
    var timer: Timer?
    let targetRadius = 10.0
    var correctionVector = CGVector(dx: 50.0, dy: 50.0)
    var imagePointer: String = "file:/Users/greg/Library/Containers/GB.IndigoPolarAlignAid/Data/img_01.jpg"
    
    func getImageURL() -> String {
        return imagePointer
    }
    
    func getCorrectionVector() -> CGVector {
        return correctionVector
    }
    
    func updateImage() {
        print("updating image...")
        while (true) {
            imagePointer = "file:/Users/greg/Library/Containers/GB.IndigoPolarAlignAid/Data/img_01.jpg"
        }
    }
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in self.updateImage() })

        let _: Task = Task {
            try await Task.sleep(for: .seconds(0.5))
            updateImage()
            print("SwClient: updates image")
        }
        
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
            print("SwClient: isCancelled is \(myClientTask.isCancelled)")
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
