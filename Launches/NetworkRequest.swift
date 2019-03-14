//
//  NetworkRequest.swift
//  Launches
//
//  Created by Matteo Manferdini on 08/03/2019.
//  Copyright © 2019 Matteo Manferdini. All rights reserved.
//

import Foundation

class NetworkRequest {
	let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
	let url: URL
	
	init(url: URL) {
		self.url = url
	}
	
	func execute(withCompletion completion: @escaping (Data?) -> Void) {
		let task = session.dataTask(with: url, completionHandler: { (data: Data?, _, _) -> Void in
			completion(data)
		})
		task.resume()
	}
}
