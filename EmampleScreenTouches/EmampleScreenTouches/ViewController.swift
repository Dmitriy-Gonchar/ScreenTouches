//
//  ViewController.swift
//  EmampleScreenTouches
//
//  Created by Jesus++ on 09.01.2023.
//

import UIKit

class ViewController: UIViewController
{
	override func viewDidLoad()
	{
		super.viewDidLoad()
		ShowTouches.show(with: .magenta.withAlphaComponent(0.66), size: 44)
	}

	@IBAction func clickInfo(_ sender: Any)
	{
		let testAlert = UIAlertController(title: "Hit test",
										  message: "test",
										  preferredStyle: .alert)
		testAlert.addAction(.init(title: "Cancel", style: .cancel))
		self.present(testAlert, animated: true)
	}

	@IBAction func stop(_ sender: Any)
	{
		ShowTouches.show = false
	}

	@IBAction func restartShow(_ sender: Any)
	{
		ShowTouches.show = true
	}
}
