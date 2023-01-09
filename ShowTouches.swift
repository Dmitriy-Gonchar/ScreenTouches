/*
 ScreenTouches
 Created by Jesus++ on 09.01.2023.

 This is free and unencumbered software released into the public domain.

 Anyone is free to copy, modify, publish, use, compile, sell, or
 distribute this software, either in source code form or as a compiled
 binary, for any purpose, commercial or non-commercial, and by any
 means.

 In jurisdictions that recognize copyright laws, the author or authors
 of this software dedicate any and all copyright interest in the
 software to the public domain. We make this dedication for the benefit
 of the public at large and to the detriment of our heirs and
 successors. We intend this dedication to be an overt act of
 relinquishment in perpetuity of all present and future rights to this
 software under copyright law.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.

 For more information, please refer to <https://unlicense.org>
 */

import UIKit

@objc extension UIWindow
{
	private static var tLayersHandler: UInt8 = 0

	var tapLayers: [CALayer]
	{
		get
		{
			objc_getAssociatedObject(self, &Self.tLayersHandler) as? [CALayer] ?? []
		}
		set
		{
			objc_setAssociatedObject(self, &Self.tLayersHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	func showTap(in position: [CGPoint],
				 color: UIColor = .white.withAlphaComponent(0.5),
				 size: CGFloat = 32)
	{
		position.forEach
		{ tap in
			let layer = CALayer()
			layer.bounds = CGRect(origin: .zero, size: .init(width: size, height: size))
			layer.backgroundColor = color.cgColor
			self.tapLayers.append(layer)
			self.layer.addSublayer(layer)
			layer.position = tap
			layer.cornerRadius = size/2
		}
	}

	func resetTap()
	{
		self.tapLayers.forEach { $0.removeFromSuperlayer() }
		self.tapLayers = []
	}
}

@objc extension UIApplication
{
	private static var oldMethod: IMP?
	private static let originalSelector = #selector(sendEvent(_:))
	private static let newSelector = #selector(sendEventNew(_:))
	private static var tapIsShow = false
	fileprivate static var tapColor: UIColor = .white.withAlphaComponent(0.5)
	fileprivate static var tapSize: CGFloat = 32

	private func tapDetectingChangeState()
	{
		let Class = Self.self

		if Self.oldMethod == nil
		{
			if let oldMethod = class_getInstanceMethod(Class,
													   Self.originalSelector)
			{
				Self.oldMethod = method_getImplementation(oldMethod)
			}

			Self.oldMethod = class_getInstanceMethod(Class,
													 Self.originalSelector)
		}

		guard let originalMethod = class_getInstanceMethod(Class, Self.originalSelector),
			  let swizzledMethod = class_getInstanceMethod(Class, Self.newSelector)
		else { return }

		let didAddMethod = class_addMethod(Class,
										   Self.originalSelector,
										   method_getImplementation(swizzledMethod),
										   method_getTypeEncoding(swizzledMethod))
		if didAddMethod
		{
			class_replaceMethod(Class, Self.newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
		}
		else
		{
			method_exchangeImplementations(originalMethod, swizzledMethod)
		}
		Self.tapIsShow = !Self.tapIsShow
	}

	func tapStopDetecting()
	{
		if nil != Self.oldMethod,
		   Self.tapIsShow
		{
			self.tapDetectingChangeState()
		}
	}

	func tapStartDetecting()
	{
		if !Self.tapIsShow
		{
			self.tapDetectingChangeState()
		}
	}

	@objc func sendEventNew(_ event: UIEvent)
	{
		self.sendEventNew(event)
		if let window = self.delegate?.window as? UIWindow,
		   let touches = event.allTouches,
		   let touch = touches.first
		{
			switch touch.phase
			{
			case .began:
				window.showTap(in: touches.map { $0.location(in: nil) }, color: Self.tapColor, size: Self.tapSize)
			case .moved:
				window.resetTap()
				window.showTap(in: touches.map { $0.location(in: nil) }, color: Self.tapColor, size: Self.tapSize)
			default:
				window.resetTap();
			}
		}
	}
}

class ShowTouches
{
	static var show: Bool = false
	{
		didSet
		{
			let app = UIApplication.shared
			(self.show ? app.tapStartDetecting : app.tapStopDetecting)()
		}
	}

	static func show(with color: UIColor, size: CGFloat)
	{
		let app = UIApplication.shared
		UIApplication.tapColor = color
		UIApplication.tapSize = size
		app.tapStartDetecting()
	}
}
