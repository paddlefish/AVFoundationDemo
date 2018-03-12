//
//  ActionCollectionViewDelegate.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit

class ActionCell: UICollectionViewCell {
	let label: UILabel
	override init(frame: CGRect) {
		
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		
		self.label = label

		super.init(frame: frame)
		
		contentView.addSubview(label)
		
		contentView.backgroundColor = UIColor.lightGray
		
		label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		label.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		label.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	struct Action {
		let title: String
		let action: () -> Void
	}
}

class ActionCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	let actions: [ActionCell.Action]
	let layoutManager = NSLayoutManager()
	let textContainer = NSTextContainer(size: CGSize(width: 10000, height: 10000))

	init(actions: [ActionCell.Action]) {
		self.actions = actions
		
		super.init()

		layoutManager.addTextContainer(textContainer)
	}
	
	func setup() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.backgroundColor = UIColor.white
		collectionView.translatesAutoresizingMaskIntoConstraints = false

		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(ActionCell.self, forCellWithReuseIdentifier: "action-cell")

		return collectionView
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		layoutManager.textStorage = NSTextStorage(string: actions[indexPath.item].title)
		layoutManager.ensureLayout(for: textContainer)
		return layoutManager.usedRect(for: textContainer).insetBy(dx: -20, dy: -20).size
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard section == 0 else {
			return 0
		}
		return actions.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "action-cell", for: indexPath)
		
		guard let actionCell = cell as? ActionCell else {
			return cell
		}
		actionCell.label.text = actions[indexPath.item].title
		
		return actionCell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		actions[indexPath.item].action()
	}
}

