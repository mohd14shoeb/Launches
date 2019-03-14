//
//  LaunchesViewController.swift
//  Launches
//
//  Created by Matteo Manferdini on 06/03/2019.
//  Copyright © 2019 Matteo Manferdini. All rights reserved.
//

import UIKit

class LaunchesViewController: UITableViewController {
	var launches: [Launch] = []
}

extension LaunchesViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		let url = URL(string: "https://api.spacexdata.com/v3/launches?limit=10")!
		let request = NetworkRequest(url: url)
		request.execute { [weak self] (data) in
			if let data = data {
				self?.decode(data)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let indexPath = tableView.indexPathForSelectedRow,
			let launchViewController = segue.destination as? LaunchViewController {
			launchViewController.launch = launches[indexPath.row]
		}
	}
}

extension LaunchesViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return launches.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchCell", for: indexPath) as! LaunchCell
		let launch = launches[indexPath.row]
		cell.missionLabel.text = launch.missionName
		cell.dateLabel.text = launch.date.formatted
		cell.statusLabel.text = launch.succeeded.formatted
		cell.patchImageView.image = launch.patch
		return cell
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		var launch = launches[indexPath.row]
		if let _ = launch.patch {
			return
		}
		let request = NetworkRequest(url: launch.patchURL)
		request.execute { [weak self](data) in
			guard let data = data else {
				return
			}
			launch.patch = UIImage(data: data)
			self?.launches[indexPath.row] = launch
			tableView.reloadRows(at: [indexPath], with: .fade)
		}
	}
}

private extension LaunchesViewController {
	func decode(_ data: Data) {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(DateFormatter.fullISO8601)
		do {
			launches = try decoder.decode([Launch].self, from: data)
			tableView.reloadData()
		} catch {
			let title = "Oops, something went wrong"
			let message = "Please make sure you have the latest version of the app."
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
			let dismissAction = UIAlertAction(title: title, style: .default, handler: nil)
			alertController.addAction(dismissAction)
			show(alertController, sender: nil)
		}
	}
}

class LaunchCell: UITableViewCell {
	@IBOutlet weak var patchImageView: UIImageView!
	@IBOutlet weak var missionLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
}
