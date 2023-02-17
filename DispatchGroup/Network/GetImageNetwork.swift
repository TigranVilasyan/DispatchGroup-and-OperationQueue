//
//  GetImageNetwork.swift
//  DispatchGroup
//
//  Created by Tigran VIasyan on 16.02.23.
//

import Foundation


class GetImageNetwork {
    func getImage(imageName: String,completion: @escaping (SearchResult) -> Void) {
        let headers = [
            "X-Proxy-Location": "EU",
            "X-User-Agent": "desktop",
            "X-RapidAPI-Key": "837f39b712msh0375f4a19618675p1a01e9jsnc6486ba5304b",
            "X-RapidAPI-Host": "seo-api.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: URL(string: "https://seo-api.p.rapidapi.com/v1/image/q=\(imageName))")!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error?.localizedDescription)
            } else {
//                let httpResponse = response as? HTTPURLResponse
                guard let data = data else { return }
                let welcome = try? JSONDecoder().decode(SearchResult.self, from: data)
                completion(welcome!)
            }
        })
        
        dataTask.resume()
    }
}
