//
//  ViewController.swift
//  DispatchGroup
//
//  Created by Tigran VIasyan on 15.02.23.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    var result1: SearchResult?
    var result2: SearchResult?
    var result3: SearchResult?
    var getImageNetwork = GetImageNetwork()
    let lock = NSLock()
    
    func request1(completion: @escaping (SearchResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.getImageNetwork.getImage(imageName: "tesla", completion: { [weak self] data in
                completion(data)
            })
        }
    }
    
    func request2(completion: @escaping (SearchResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.getImageNetwork.getImage(imageName: "Mercedes") { [weak self] data in
                completion(data)
            }
        }
    }
    
    func request3(completion: @escaping (SearchResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.getImageNetwork.getImage(imageName: "bmw") { [weak self] data in
                completion(data)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        dispatchGroupCall()
        operationQueue()
    }
    
    
    func operationQueue() {
        let op1 = Operation()
        let op2 = Operation()
        let op3 = Operation()
        let op4 = Operation()
        let operationQueue = OperationQueue()
        op1 ==> op2 ==> op3 ==> op4
        operationQueue.addOperation(op1)
        operationQueue.addOperation(op2)
        operationQueue.addOperation(op3)
        operationQueue.addOperation(op4)
        op1.completionBlock = {
            self.lock.lock()
            print("First")
            self.request1 { [weak self] data in
                self?.result1 = data
                self?.lock.unlock()
                print("Request 1 completed")
                
            }
        }
        op2.completionBlock = {
            self.lock.lock()
            print("Second")
            self.request2 { [weak self] data in
                self?.result2 = data
                self?.lock.unlock()
                print("Request 2 completed")
            }
        }
        
        op3.completionBlock = {
            self.lock.lock()
            print("Third")
            self.request3 { [weak self] data in
                self?.result3 = data
                self?.lock.unlock()
                print("Request 3 completed")
            }
        }
        
        op4.completionBlock = {
            print("Fourth")
            self.lock.lock()
            self.imageView1.sd_setImage(with: URL(string: (self.result1?.imageResults[0].image.src)!))
            self.imageView2.sd_setImage(with: URL(string: (self.result2?.imageResults[0].image.src)!))
            self.imageView3.sd_setImage(with: URL(string: (self.result3?.imageResults[0].image.src)!))
            self.lock.unlock()
            print("All requests completed")
        }
    }
    
    func dispatchGroupCall() {
        let requestsGroup = DispatchGroup()
        requestsGroup.enter()
        request1 { [weak self] data in
            self?.result1 = data
            print("Request 1 completed")
            requestsGroup.leave()
        }
        requestsGroup.enter()
        request2 { [weak self] data in
            self?.result2 = data
            print("Request 2 completed")
            requestsGroup.leave()
        }
        requestsGroup.enter()
        request3 { [weak self] data in
            self?.result3 = data
            print("Request 3 completed")
            requestsGroup.leave()
        }
        
        requestsGroup.notify(queue: .main) { [self] in
            imageView1.sd_setImage(with: URL(string: (self.result1?.imageResults[0].image.src)!))
            imageView2.sd_setImage(with: URL(string: (self.result2?.imageResults[0].image.src)!))
            imageView3.sd_setImage(with: URL(string: (self.result3?.imageResults[0].image.src)!))
            print("All requests completed")
        }
    }
}


precedencegroup OperationChaining {
    associativity: left
}
infix operator ==> : OperationChaining

@discardableResult
func ==><T: Operation>(lhs: T, rhs: T) -> T {
    rhs.addDependency(lhs)
    return rhs
}
