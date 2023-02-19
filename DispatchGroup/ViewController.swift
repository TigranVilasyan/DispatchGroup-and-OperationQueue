//
//  ViewController.swift
//  DispatchGroup
//
//  Created by Tigran VIasyan on 15.02.23.
//

import UIKit
import SDWebImage
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    var result1: SearchResult? {
        didSet {
            guard let imagePath = result1?.imageResults[0].image.src,
                  let url = URL(string: imagePath) else { return }
            self.imageView1.downloaded(from: url)
        }
    }
    var result2: SearchResult? {
        didSet {
            guard let imagePath = result2?.imageResults[0].image.src,
                  let url = URL(string: imagePath) else { return }
            self.imageView2.downloaded(from: url)
        }
    }
    var result3: SearchResult? {
        didSet {
            guard let imagePath = result3?.imageResults[0].image.src,
                  let url = URL(string: imagePath) else { return }
            self.imageView3.downloaded(from: url)
        }
    }
    
    var getImageNetwork = GetImageNetwork()
    var dispatchQueue = DispatchQueue(label: "NetworkThread",qos: .background)
    
    func request1(completion: @escaping (SearchResult) -> Void) {
        dispatchQueue.async {
            self.getImageNetwork.getImage(imageName: "tesla", completion: { data in
                completion(data)
            })
        }
    }
    
    func request2(completion: @escaping (SearchResult) -> Void) {
        dispatchQueue.async {
            self.getImageNetwork.getImage(imageName: "Mercedes") { data in
                completion(data)
            }
        }
    }
    
    func request3(completion: @escaping (SearchResult) -> Void) {
        dispatchQueue.async {
            self.getImageNetwork.getImage(imageName: "bmw") { data in
                completion(data)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatchGroupCall()
//        operationQueue()
    }
    
    
    func operationQueue() {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background
        
        let op1 = Operation()
        op1.completionBlock = {
            print("First")
            self.request1 { [weak self] data in
                self?.result1 = data
                print("Request 1 completed")
            }
        }
        
        let op2 = Operation()
        op2.completionBlock = {
            print("Second")
            self.request2 { [weak self] data in
                self?.result2 = data
                print("Request 2 completed")
                
            }
        }
        op1 ==> op2
        
        let op3 = Operation()
        op3.completionBlock = {
            print("Third")
            self.request3 { [weak self] data in
                self?.result3 = data
                print("Request 3 completed")
            }
        }
        op2 ==> op3
        
        operationQueue.addOperations([op1, op2, op3], waitUntilFinished: true)
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
        
        requestsGroup.notify(queue: .main) {
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
