//
//  BackgroundColorButton.swift
//
//  Created by Robert Vaessen on 12/16/15.
//  Copyright © 2015 Robert Vaessen. All rights reserved.
//

import UIKit

public extension UIButton {
    public func setBackgroundColor(_ color: UIColor?, forState state: UIControlState) {
        if let color = color {
            setBackgroundImage(color.toImage(), for: state)
        }
        else {
            setBackgroundImage(nil, for: state)
        }
    }
}

@IBDesignable
open class ColoredButton: UIButton {
    @IBInspectable open var color: UIColor? {
        didSet {
            setBackgroundColor(color, forState: UIControlState())
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

@IBDesignable
open class ToggleButton: ColoredButton {
    
    open var listener: ((Bool) -> Void)?
    
    @IBInspectable open var selectedColor: UIColor? {
        didSet {
            setBackgroundColor(selectedColor, forState: .selected)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private func initialize() {
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    open func toggle() {
        isSelected = !isSelected
        if let listener = listener { listener(isSelected) }
    }
}

@IBDesignable
public class RadioButton: UIButton {
    
    internal var outerCircleLayer = CAShapeLayer()
    internal var innerCircleLayer = CAShapeLayer()
    
    
    @IBInspectable public var outerCircleColor: UIColor = UIColor.green {
        didSet {
            outerCircleLayer.strokeColor = outerCircleColor.cgColor
        }
    }
    @IBInspectable public var innerCircleColor: UIColor = UIColor.green {
        didSet {
            setFillState()
        }
    }
    
    @IBInspectable public var outerCircleLineWidth: CGFloat = 3.0 {
        didSet {
            setCircleLayouts()
        }
    }
    @IBInspectable public var innerCircleGap: CGFloat = 3.0 {
        didSet {
            setCircleLayouts()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        customInitialization()
    }

    // MARK: Initialization
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInitialization()
    }

    internal var setCircleRadius: CGFloat {
        let width = bounds.width
        let height = bounds.height
        
        let length = width > height ? height : width
        return (length - outerCircleLineWidth) / 2
    }
    
    private var setCircleFrame: CGRect {
        let width = bounds.width
        let height = bounds.height
        
        let radius = setCircleRadius
        let x: CGFloat
        let y: CGFloat
        
        if width > height {
            y = outerCircleLineWidth / 2
            x = (width / 2) - radius
        } else {
            x = outerCircleLineWidth / 2
            y = (height / 2) - radius
        }
        
        let diameter = 2 * radius
        return CGRect(x: x, y: y, width: diameter, height: diameter)
    }
    
    private var circlePath: UIBezierPath {
        return UIBezierPath(roundedRect: setCircleFrame, cornerRadius: setCircleRadius)
    }
    
    private var fillCirclePath: UIBezierPath {
        let trueGap = innerCircleGap + (outerCircleLineWidth / 2)
        return UIBezierPath(roundedRect: setCircleFrame.insetBy(dx: trueGap, dy: trueGap), cornerRadius: setCircleRadius)
        
    }
    
    private func customInitialization() {
        outerCircleLayer.frame = bounds
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.strokeColor = outerCircleColor.cgColor
        layer.addSublayer(outerCircleLayer)
        
        innerCircleLayer.frame = bounds
        innerCircleLayer.lineWidth = outerCircleLineWidth
        innerCircleLayer.fillColor = UIColor.clear.cgColor
        innerCircleLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(innerCircleLayer)
        
        setFillState()
    }
    
    private func setCircleLayouts() {
        outerCircleLayer.frame = bounds
        outerCircleLayer.lineWidth = outerCircleLineWidth
        outerCircleLayer.path = circlePath.cgPath
        
        innerCircleLayer.frame = bounds
        innerCircleLayer.lineWidth = outerCircleLineWidth
        innerCircleLayer.path = fillCirclePath.cgPath
    }
    
    // MARK: Custom
    private func setFillState() {
        if self.isSelected {
            innerCircleLayer.fillColor = outerCircleColor.cgColor
        } else {
            innerCircleLayer.fillColor = UIColor.clear.cgColor
        }
    }

    // Overriden methods.

    override public func prepareForInterfaceBuilder() {
        customInitialization()
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        setCircleLayouts()
    }
    override public var isSelected: Bool {
        didSet {
            setFillState()
        }
    }
}

@IBDesignable
public class DropDownButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initialize()
    }
    
    fileprivate func initialize() {
        if image(for: .normal) == nil {
            if let image = UIImage(named: "DropDown", in: Bundle(for: DropDownButton.self), compatibleWith: nil) {
                setImage(image, for: .normal)
            }
        }
        
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        sizeToFit()
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if var imageFrame = imageView?.frame, var labelFrame = titleLabel?.frame, let count = titleLabel?.text?.characters.count {
            
            if (count > 0) {
                labelFrame.origin.x = contentEdgeInsets.left
                imageFrame.origin.x = labelFrame.origin.x + labelFrame.width + 2
                
                imageView?.frame = imageFrame
                titleLabel?.frame = labelFrame
            }
            
        }
    }
    
    public override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        sizeToFit()
    }
    
    public var collapsed: Bool {
        return imageView?.transform == CGAffineTransform.identity
    }
    
    public var expanded: Bool {
        return !collapsed
    }
    
    fileprivate func collapse() {
        imageView?.transform = CGAffineTransform.identity
    }
    
    private func expand() {
        imageView?.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    @objc fileprivate func toggle(sender: UIButton) {
        if collapsed { expand() } else { collapse() }
    }
}

public class DropDownMenuButton: DropDownButton, UIPopoverPresentationControllerDelegate {
    
    private class Menu {
        let items: [CustomStringConvertible]
        var selection: Int {
            didSet {
                selectionChangedHandler(items[selection])
            }
        }
        let selectionChangedHandler: ((CustomStringConvertible) -> Void)
        
        init(items: [CustomStringConvertible], initialSelection: Int, selectionChangedHandler: @escaping ((CustomStringConvertible) -> Void)) {
            self.items = items
            self.selection = initialSelection
            self.selectionChangedHandler = selectionChangedHandler
        }
    }
    
    private class MenuViewController: UITableViewController {
        
        var menu: Menu!
        let cellId = "MenuCell"
        
        override func viewDidLoad() {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return menu.items.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            cell.textLabel?.text = menu.items[indexPath.row].description
            cell.accessoryType = indexPath.item == menu.selection ? .checkmark : .none
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            menu.selection = indexPath.item
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private var menu: Menu?
    
    public func setMenu(items: [CustomStringConvertible], initialSelection: Int, selectionChangedHandler: @escaping ((CustomStringConvertible) -> Void)) -> Bool {
        guard items.count > 0 && initialSelection >= 0 && initialSelection < items.count else { return false }
        
        menu = Menu(items: items, initialSelection: initialSelection, selectionChangedHandler: {
            self.collapse()
            self.setTitle($0.description, for: .normal)
            
            selectionChangedHandler($0)
        })
        
        setTitle(menu!.items[menu!.selection].description, for: .normal)
        
        return true
    }
    
    fileprivate override func initialize() {
        super.initialize()
        setTitle("<no items>", for: .normal)
    }
    
    @objc fileprivate override func toggle(sender: UIButton) {
        super.toggle(sender: sender)
        
        if collapsed { return }
        
        guard let menu = self.menu else { return }
        
        let menuVC = MenuViewController()
        menuVC.menu = menu
        menuVC.modalPresentationStyle = .popover
        menuVC.preferredContentSize = CGSize(width: 225, height: 250) // TODO: Calculate the preferred size from the actual content.
        let popoverController = menuVC.popoverPresentationController!
        popoverController.sourceView = self
        popoverController.delegate = self
        
        self.viewController?.present(menuVC, animated: true, completion: nil)
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        collapse()
        return true
    }
}
