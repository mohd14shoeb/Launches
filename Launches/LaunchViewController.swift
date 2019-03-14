//
//  LaunchViewController.swift
//  Launches
//
//  Created by Matteo Manferdini on 04/03/2019.
//  Copyright © 2019 Matteo Manferdini. All rights reserved.
//

import UIKit

class LaunchViewController: UITableViewController {
	@IBOutlet weak var missionNameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var payloadDeploymentTimeLabel: UILabel!
	@IBOutlet weak var payloadsLabel: UILabel!
	@IBOutlet weak var mecoTimeLabel: UILabel!
	@IBOutlet weak var liftoffTimeLabel: UILabel!
	@IBOutlet weak var rocketLabel: UILabel!
	@IBOutlet weak var loadingTimeLabel: UILabel!
	@IBOutlet weak var siteLabel: UILabel!
	@IBOutlet weak var patchActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var patchImageView: UIImageView!
	
	private var isRefreshing = true
	var launch: Launch?
}

extension LaunchViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = .white
		tableView.refreshControl = refreshControl
		tableView.contentOffset = CGPoint(x:0, y:-refreshControl.frame.size.height)
		tableView.refreshControl?.beginRefreshing()
		fetchLaunch()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isRefreshing ? 0 : super.tableView(tableView, numberOfRowsInSection: 0)
	}
}

private extension LaunchViewController {
	func fetchLaunch() {
		guard let launch = launch else {
			return
		}
		let url = URL(string: "https://api.spacexdata.com/v3/launches")!
			.appendingPathComponent("\(launch.flightNumber)")
		let request = NetworkRequest(url: url)
		request.execute { [weak self] (data) in
			self?.isRefreshing = false
			self?.tableView.reloadData()
			self?.tableView.refreshControl?.endRefreshing()
			if let data = data {
				self?.decode(data)
			}
		}
	}
	
	func decode(_ data: Data) {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(DateFormatter.fullISO8601)
		if let launch = try? decoder.decode(Launch.self, from: data) {
			set(launch)
		}
	}
	
	func set(_ launch: Launch) {
		missionNameLabel.text = launch.missionName
		dateLabel.text = launch.date.formatted
		statusLabel.text = launch.succeeded ? "Succeeded" : "Failed"
		siteLabel.text = launch.site
		rocketLabel.text = launch.rocket
		payloadsLabel.text = launch.payloads
		
		let timeline = launch.timeline
		loadingTimeLabel.text = timeline?.propellerLoading?.formatted
		liftoffTimeLabel.text = timeline?.liftoff?.formatted
		mecoTimeLabel.text = timeline?.mainEngineCutoff?.formatted
		payloadDeploymentTimeLabel.text = timeline?.payloadDeploy?.formatted
		
		fetchPatch(withURL: launch.patchURL)
	}
	
	func fetchPatch(withURL url: URL) {
		let request = NetworkRequest(url: url)
		request.execute { [weak self] (data) in
			guard let data = data else {
				return
			}
			self?.patchImageView.image = UIImage(data: data)
			self?.patchActivityIndicator.stopAnimating()
		}
	}
}

extension Date {
	var formatted: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .long
		return formatter.string(from: self)
	}
}

extension DateFormatter {
	static let fullISO8601: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
}

extension Int {
	var formatted: String {
		let sign = self >= 0 ? "+" : ""
		return "T" + sign + "\(self)"
	}
}

extension Bool {
	var formatted: String {
		return self ? "Succeeded" : "Failed"
	}
}
