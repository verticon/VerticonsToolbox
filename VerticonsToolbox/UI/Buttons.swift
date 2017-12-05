//
//  Buttons.swift
//
//  Created by Robert Vaessen on 4/15/17.
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
    
    @objc open func toggle() {
        isSelected = !isSelected
        if let listener = listener { listener(isSelected) }
    }
}

@IBDesignable
public class RadioButton: UIButton {
    
    public var listener: ((Bool) -> Void)?

    internal var bevelLayer = CAShapeLayer()
    internal var buttonLayer = CAShapeLayer()
    
    
    @IBInspectable public var bezelColor: UIColor = UIColor.lightGray {
        didSet {
            bevelLayer.strokeColor = bezelColor.cgColor
        }
    }

    @IBInspectable public var bezelWidth: CGFloat = 2.0 {
        didSet {
            layoutSubLayers()
        }
    }

    @IBInspectable public var bezelButtonGap: CGFloat = 4.0 {
        didSet {
            layoutSubLayers()
        }
    }

    @IBInspectable public var buttonColor: UIColor = UIColor.lightGray {
        didSet {
            indicateButtonState()
        }
    }
    
    @IBInspectable  public fileprivate(set) var isPressed: Bool = false {
        didSet {
            indicateButtonState()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    // MARK: Initialization
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        bevelLayer.frame = bounds
        bevelLayer.lineWidth = bezelWidth
        bevelLayer.fillColor = UIColor.clear.cgColor
        bevelLayer.strokeColor = bezelColor.cgColor
        layer.addSublayer(bevelLayer)
        
        buttonLayer.frame = bounds
        buttonLayer.lineWidth = bezelWidth
        buttonLayer.fillColor = UIColor.clear.cgColor
        buttonLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(buttonLayer)
        
        addTarget(self, action: #selector(pressHandler(_:)), for: .touchUpInside)

        indicateButtonState()
    }
    
    override public func prepareForInterfaceBuilder() {
        initialize()
    }
    
    @objc private func pressHandler(_ sender: RadioButton) {
        isPressed = !isPressed
        if let listener = listener { listener(isPressed) }
    }

    private var bezelInnerRadius: CGFloat {
        let width = bounds.width
        let height = bounds.height
        
        let maxSide = width > height ? height : width
        return (maxSide - bezelWidth) / 2
    }
    
    private var bezelInnerFrame: CGRect {
        let width = bounds.width
        let height = bounds.height
        
        let radius = bezelInnerRadius
        let x: CGFloat
        let y: CGFloat
        
        if width > height {
            y = bezelWidth / 2
            x = (width / 2) - radius
        } else {
            x = bezelWidth / 2
            y = (height / 2) - radius
        }
        
        let diameter = 2 * radius
        return CGRect(x: x, y: y, width: diameter, height: diameter)
    }
    
    private var bezelPath: UIBezierPath {
        return UIBezierPath(roundedRect: bezelInnerFrame, cornerRadius: bezelInnerRadius)
    }
    
    private var buttonPath: UIBezierPath {
        let trueGap = bezelButtonGap + (bezelWidth / 2)
        return UIBezierPath(roundedRect: bezelInnerFrame.insetBy(dx: trueGap, dy: trueGap), cornerRadius: bezelInnerRadius)
        
    }
    
    private func layoutSubLayers() {
        bevelLayer.frame = bounds
        bevelLayer.lineWidth = bezelWidth
        bevelLayer.path = bezelPath.cgPath
        
        buttonLayer.frame = bounds
        buttonLayer.lineWidth = bezelWidth
        buttonLayer.path = buttonPath.cgPath
    }
    
    private func indicateButtonState() {
        buttonLayer.fillColor = isPressed ? bezelColor.cgColor : UIColor.clear.cgColor
    }

   override public func layoutSubviews() {
        super.layoutSubviews()
        layoutSubLayers()
    }
}

public class RadioButtonGroup {
    private let group: [RadioButton]
    private let changeHandler: (RadioButton) -> Void
    
    public init(buttons: RadioButton ..., initialSelection: RadioButton, selectionChangedHandler: @escaping (RadioButton) -> Void) {
        group = buttons
        changeHandler = selectionChangedHandler

        group.forEach { button in
            button.addTarget(self, action: #selector(pressHandler(_:)), for: .touchUpInside)
        }
        set(selected: initialSelection)
    }

    public func set(hidden: Bool) {
        group.forEach { $0.isHidden = hidden }
    }
    
    public func set(enabled: Bool) {
        group.forEach { $0.isEnabled = enabled }
    }
    
    public func set(selected: RadioButton) {
        group.forEach { $0.isPressed = $0 == selected }
    }
    
    @objc private func pressHandler(_ sender: RadioButton) {
        group.forEach { $0.isPressed = $0 === sender }
        if sender.isPressed { changeHandler(sender) }
    }
}

@IBDesignable
public class DropDownButton: UIButton, UIPopoverPresentationControllerDelegate {
    
    private var popoverViewController: UIViewController?

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
            setImage(UIImage(named: "DropDown", in: Bundle(for: DropDownButton.self), compatibleWith: nil), for: .normal)
        }
        
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        sizeToFit()
    }
    
    // If the popover has been presented and then the button's view controller is dismissed due to an event other
    //  than a screen touch, the popover will stay on the screen. Let's detect that and dismiss the popover if it occurs
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil, let popover = popoverViewController {
            popover.dismiss(animated: true, completion: nil)
        }
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if var imageFrame = imageView?.frame, var labelFrame = titleLabel?.frame, let count = titleLabel?.text?.count {
            
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
    
    public func trigger() {
        toggle(sender: self)
    }

    public var color : UIColor = UIColor.gray {
        didSet {
            if let image = imageView?.image {
                setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
                tintColor = color
            }
        }
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

        if collapsed { return }
        
        guard let viewController = makePopoverViewController() else { return }

        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = CGSize(width: 225, height: 250) // TODO: Calculate the preferred size from the actual content.
        let presentationController = viewController.popoverPresentationController!
        presentationController.delegate = self
        if let barButton = outerButton { presentationController.barButtonItem = barButton } else { presentationController.sourceView = self.imageView }
        self.viewController?.present(viewController, animated: true, completion: nil)

        popoverViewController = viewController
    }

    fileprivate func makePopoverViewController() -> UIViewController? {
        return nil
    }

    fileprivate var outerButton: DropDownBarButton? // This button might be the custom view of a bar button item (see the UIBarButtonItem subclasses below)

    // MARK: UIPopoverPresentationControllerDelegate
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        popoverViewController = nil
        collapse()
        return true
    }
}

// TODO: Consider what to do when a list item's description does not fit.
@IBDesignable
public class DropDownListButton: DropDownButton {
    
    fileprivate class List {
        let items: [CustomStringConvertible]

        init(items: [CustomStringConvertible]) {
            self.items = items
        }
    }
    
    fileprivate class ListViewController: UITableViewController {
        
        private var list: List
        private let cellId = "ListCell"
        
        init(list: List) {
            self.list = list
            super.init(style: .plain)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return list.items.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            cell.textLabel?.text = list.items[indexPath.row].description
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    private var list: List?

    public func setList(items: [CustomStringConvertible]) -> Self? {
        guard items.count > 0 else { return nil }
        
        list = List(items: items)
        
        return self
    }
    
    fileprivate override func makePopoverViewController() -> UIViewController? {
        guard let list = self.list else { return nil }
        return ListViewController(list: list)
    }
}

@IBDesignable
public class DropDownMenuButton: DropDownButton {

    private class Menu : DropDownListButton.List {
        var selection: Int {
            didSet {
                selectionHandler(items[selection])
            }
        }
        let selectionHandler: ((CustomStringConvertible) -> Void)
        
        init(items: [CustomStringConvertible], initialSelection: Int, selectionHandler: @escaping ((CustomStringConvertible) -> Void)) {
            self.selection = initialSelection
            self.selectionHandler = selectionHandler
            
            super.init(items: items)
        }

        public var selectedItem: CustomStringConvertible {
            return items[selection]
        }
        
    }
    
    private class MenuViewController: DropDownListButton.ListViewController {
        
        private var menu: Menu

        init(menu: Menu) {
            self.menu = menu
            super.init(list: menu)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.accessoryType = indexPath.item == menu.selection ? .checkmark : .none
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            menu.selection = indexPath.item
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private var menu: Menu?

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setTitle("Menu", for: .normal)
    }
    
    public func setMenu(items: [CustomStringConvertible], initialSelection: Int, selectionHandler: @escaping ((CustomStringConvertible) -> Void)) -> Self? {
        guard items.count > 0 && initialSelection >= 0 && initialSelection < items.count else { return nil }
        
        menu = Menu(items: items, initialSelection: initialSelection, selectionHandler: { selection in
            
            self.collapse()
            self.setTitle(selection.description, for: .normal)
            
            // A situation was encountered wherein the selection handler attempted to present an alert.
            // The alert did not appear and the dismissal of the popover was interfered with. Hence we
            // delay the invocation of the handler until the popover has been fully dismissed (100 ms
            // was too short a time).
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                selectionHandler(selection)
            }
        })
        
        setTitle(menu!.items[initialSelection].description, for: .normal)
        
        return self
    }

    public var selectedItem: CustomStringConvertible? {
        return menu?.selectedItem
    }

    fileprivate override func makePopoverViewController() -> UIViewController? {
        guard let menu = self.menu else { return nil }
        return MenuViewController(menu: menu)
    }
}

public class DropDownBarButton: UIBarButtonItem {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initialize()
    }
    
    fileprivate func initialize() {
        innerButton.outerButton = self
        customView = innerButton
    }

    private let _innerButton = DropDownButton()
    fileprivate var innerButton: DropDownButton { return _innerButton }
}

public class DropDownListBarButton: DropDownBarButton {
    
    public func setList(items: [CustomStringConvertible]) -> Self? {
        return innerButton.setList(items: items) == nil ? nil : self
    }

    private let _innerButton = DropDownListButton()
    fileprivate override var innerButton: DropDownListButton { return _innerButton }
}

public class DropDownMenuBarButton: DropDownBarButton {
    
    public func setMenu(items: [CustomStringConvertible], initialSelection: Int, selectionHandler: @escaping ((CustomStringConvertible) -> Void)) -> Self? {
        return innerButton.setMenu(items: items, initialSelection: initialSelection, selectionHandler: selectionHandler) == nil ? nil : self
    }

    private let _innerButton = DropDownMenuButton()
    fileprivate override var innerButton: DropDownMenuButton { return _innerButton }

    public var selectedItem: CustomStringConvertible? {
        return innerButton.selectedItem
    }
    }

