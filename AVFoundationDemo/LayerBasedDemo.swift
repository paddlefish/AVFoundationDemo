//
//  LayerBasedDemo.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/12/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import Foundation
import UIKit

protocol LayerBasedDemo: class {

	var demoView: DemoParentLayerView! { get }

	func setupLayer()
	func setupActions() -> [ActionCell.Action]
}

extension LayerBasedDemo {
	
	var layer: CALayer! {
		return parentLayer.myLayer
	}
	
	var parentLayer: DemoParentLayer! {
		return demoView.parentLayer
	}

	@discardableResult
	func addInfoLabel(toView view: UIView) -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(label)

		label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
		label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
		label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true

		return label
	}

	@discardableResult
	func setup(layerView: DemoParentLayerView, inView view: UIView) -> DemoParentLayerView {
		layerView.parentLayer.build()
		layerView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(layerView)

		layerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		layerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
		layerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
		layerView.widthAnchor.constraint(equalTo: layerView.heightAnchor).isActive = true

		return layerView
	}

	func addActionsView(toView view: UIView, belowView: UIView, actions: [ActionCell.Action]) -> ActionCollectionViewDelegate {
		let delegate = ActionCollectionViewDelegate(actions: actions)
		
		let collectionView = delegate.setup()
		
		view.addSubview(collectionView)
		
		collectionView.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 10).isActive = true
		collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
		collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true

		return delegate
	}
	
	func setupDemoView(layerView: DemoParentLayerView) -> (UIView, DemoParentLayerView, ActionCollectionViewDelegate, UILabel)  {
		let view = UIView()
		view.backgroundColor = UIColor.white

		let label = addInfoLabel(toView: view)
		
		let layerView = setup(layerView: layerView, inView: view)
		
		let actions = setupActions()
		
		let actionDelegate = addActionsView(toView: view, belowView: layerView, actions: actions)
		
		layerView.parentLayer.myLayer.delegate = NoAnimationLayerDelegate.shared
		
		return (view, layerView, actionDelegate, label)
	}
}
