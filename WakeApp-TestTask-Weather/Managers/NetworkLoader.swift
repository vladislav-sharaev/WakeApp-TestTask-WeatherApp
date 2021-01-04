//
//  NetworkLoader.swift
//  WakeApp-TestTask-Weather
//
//  Created by Vladislav Sharaev on 12/30/20.
//

import Foundation
import UIKit

class NetworkLoader {
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.configuration)
    typealias NetworkLoaderCompletion<T> = (Result<T, NetworkError>) -> Void
    
    func downloadImage(url: URL, completion: @escaping NetworkLoaderCompletion<Data>) {
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if (response as? HTTPURLResponse) != nil {
                    if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.requestFailed))
                    }
                }
            } else {
                print("Error donwload data \(error!.localizedDescription)")
                completion(.failure(.unknown))
            }
        }
        dataTask.resume()
    }
    
    func loadData<T: Codable>(jsonUrlString: String, completion: @escaping NetworkLoaderCompletion<T>) {
        guard let url = URL(string: jsonUrlString) else {
            completion(.failure(.badURL))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("Error data: ", error.debugDescription)
                completion(.failure(.requestFailed))
                return
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
                
            } catch let jsonError {
                print("Eror with json:", jsonError)
                completion(.failure(.mapping))
            }
        }.resume()
    }
}
