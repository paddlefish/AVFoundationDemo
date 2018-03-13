//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	let rows = [ LayerViewController.self, AnimationViewController.self, KeyframeAnimationController.self,
		MovieController.self ]
	let labels = [ "Layers", "Basic Animations", "Keyframe Animations", "Movie" ]
	override func loadView() {
 		let view = UITableView()
 		view.dataSource = self
 		view.delegate = self
		
 		self.view = view
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard section == 0 else {
			return 0
		}
		return rows.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		cell.textLabel?.text = labels[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let clazz = rows[indexPath.row]
		let vc = clazz.init()
		navigationController?.show(vc, sender: self)
	}
}

