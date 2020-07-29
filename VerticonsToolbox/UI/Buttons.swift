//
//  Buttons.swift
//
//  Created by Robert Vaessen on 4/15/17.
//  Copyright © 2015 Robert Vaessen. All rights reserved.
//

import UIKit

public extension UIButton {
    func setBackgroundColor(_ color: UIColor?, forState state: UIControl.State) {
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
            setBackgroundColor(color, forState: .normal)
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

    private var bezelLayer = CAShapeLayer()
    private var buttonLayer = CAShapeLayer()
    
    
    @IBInspectable @objc dynamic public var bezelColor: UIColor = UIColor.lightGray {
        didSet {
            bezelLayer.strokeColor = bezelColor.cgColor
        }
    }

    @IBInspectable @objc dynamic public var bezelWidth: CGFloat = 2.0 {
        didSet {
            layoutSubLayers()
        }
    }

    @IBInspectable @objc dynamic public var bezelButtonGap: CGFloat = 4.0 {
        didSet {
            layoutSubLayers()
        }
    }

    @IBInspectable @objc dynamic public var buttonColor: UIColor = UIColor.lightGray {
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
        bezelLayer.frame = bounds
        bezelLayer.lineWidth = bezelWidth
        bezelLayer.fillColor = UIColor.clear.cgColor
        bezelLayer.strokeColor = bezelColor.cgColor
        layer.addSublayer(bezelLayer)
        
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
        bezelLayer.frame = bounds
        bezelLayer.lineWidth = bezelWidth
        bezelLayer.path = bezelPath.cgPath
        
        buttonLayer.frame = bounds
        buttonLayer.lineWidth = bezelWidth
        buttonLayer.path = buttonPath.cgPath
    }
    
    private func indicateButtonState() {
        buttonLayer.fillColor = isPressed ? buttonColor.cgColor : UIColor.clear.cgColor
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
 
    public var listBackgroundColor: UIColor = .white
    public var itemBackgroundColor: UIColor = .white
    public var itemTextColor: UIColor = .black

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
    
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        sizeToFit()
    }
    
    public func trigger() {
        toggle(sender: self)
    }

    @IBInspectable @objc dynamic public var color : UIColor = UIColor.gray {
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
        viewController.preferredContentSize = CGSize(width: 2 * UIWindow.mainWindow.bounds.width / 3, height: UIWindow.mainWindow.bounds.height / 4)
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

@IBDesignable
public class DropDownListButton: DropDownButton {
    
    fileprivate class List {
        let items: [CustomStringConvertible]

        init(items: [CustomStringConvertible]) {
            self.items = items
        }
    }
    
    fileprivate class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

        // The ListCell contains a scroll view which allows text that is wider than the width of the table to be seen.
        // That scroll view's contentSize os set in such a way (see ListViewController.cellforRowAt) as that vertical
        // scrolling is disabled. The presense of the scroll view prevents rows from being selected (ie. taps do not
        // reach the cell). A tap gesture recognizer is used to select the row and invoke the table delegate's didSelectRowAt
        // method.
        class ListCell : UITableViewCell {

            let item = UILabel()
            let scrollView = UIScrollView()

            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

                super.init(style: style, reuseIdentifier: reuseIdentifier)

                item.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(item)
                NSLayoutConstraint.activate([
                    item.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10),
                    item.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
                    item.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
                ])

                scrollView.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(scrollView)
                NSLayoutConstraint.activate([
                    scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                    scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                    scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                ])

                let tapHandler = UITapGestureRecognizer(target: self, action: #selector(selectRow))
                scrollView.addGestureRecognizer(tapHandler)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            @objc private func selectRow(_ recognizer: UITapGestureRecognizer) {
                switch recognizer.state {
                case .ended:
                    // Traverse the view hierarchy to find first the cell and then the table.
                    // When they have both been found, invoke the table delegate's didSelectRowAt method
                    func selectRow(current: UIView, cell: UITableViewCell?) {

                        if let cell = cell { // We've already found the cell; we're looking for the table
                            if let table = current as? UITableView {
                                guard let index = table.indexPath(for: cell) else { fatalError("No index path for the cell that was tapped.") }
                                //table.delegate?.tableView?(table, didDeselectRowAt: index) Why did this not work???
                                if let vc = table.delegate as? DropDownListButton.ListViewController {
                                    table.selectRow(at: index, animated: true, scrollPosition: .none)
                                    vc.tableView(table, didSelectRowAt: index)
                                }
                                //table.reloadData()
                            }
                            else { // Keep looking for the table
                                guard let next = cell.superview else { fatalError("We reached the top of the view hierarchy without finding the table.")  }
                                selectRow(current: next, cell: cell)
                            }
                        }
                        else { // Keep looking for the cell
                            guard let next = current.superview else { fatalError("We reached the top of the view hierarchy without finding the cell and the table.")  }
                            selectRow(current: next, cell: current as? UITableViewCell)
                        }
                    }

                    selectRow(current: self, cell: nil)

                default: break
                }
            }
        }

        let cellBackgroundColor: UIColor
        let cellTextColor: UIColor

        private var tableView = UITableView()
        private var list: List
        private let cellId = "DropDownListCell"

        init(list: List, title: String?, tableBackgroundColor: UIColor, cellBackgroundColor: UIColor, cellTextColor: UIColor) {
            self.list = list
            self.cellBackgroundColor = cellBackgroundColor
            self.cellTextColor = cellTextColor

            super.init(nibName: nil, bundle: nil)

            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            NSLayoutConstraint.activate([
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            tableView.delegate = self
            tableView.dataSource = self

            if let title = title {
                let header = UILabel()
                header.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
                header.text = title
                header.textAlignment = .center
                tableView.tableHeaderView = header
            }
 
            // tableView.bounces = false
            tableView.backgroundColor = tableBackgroundColor

            tableView.register(ListCell.self, forCellReuseIdentifier: cellId)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return list.items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let _cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            guard let cell = _cell as? ListCell else { return _cell }

            cell.item.textColor = cellTextColor
            cell.item.backgroundColor = cellBackgroundColor
            cell.item.text = list.items[indexPath.row].description

            // Apparently, a height of 0 causes the content view's height to be the height of its content; effectively disabling vertical scrolling.
            cell.scrollView.contentSize = CGSize(width: cell.item.intrinsicContentSize.width + 20, height: 0)
            cell.scrollView.backgroundColor = cellBackgroundColor

            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    private var list: List?
    private var title: String?

    public init(listBackgroundColor: UIColor = .white, itemBackgroundColor: UIColor = .white, itemTextColor: UIColor = .black) {
        super.init(frame: CGRect.zero)

        self.listBackgroundColor = listBackgroundColor
        self.itemBackgroundColor = itemBackgroundColor
        self.itemTextColor = itemTextColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setList(title: String?, items: [CustomStringConvertible]) {
        self.title = title
        list = List(items: items)
    }
    
    fileprivate override func makePopoverViewController() -> UIViewController? {
        guard let list = self.list else { return nil }
        return ListViewController(list: list, title: title, tableBackgroundColor: listBackgroundColor, cellBackgroundColor: itemBackgroundColor, cellTextColor: itemTextColor)
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

        init(menu: Menu, title: String?, tableBackgroundColor: UIColor, cellBackgroundColor: UIColor, cellTextColor: UIColor) {
            self.menu = menu
            super.init(list: menu, title: title, tableBackgroundColor: tableBackgroundColor, cellBackgroundColor: cellBackgroundColor, cellTextColor: cellTextColor)
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
            super.tableView(tableView, didSelectRowAt: indexPath)
            menu.selection = indexPath.item
            self.dismiss(animated: true, completion: nil)
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let accessory = cell.accessoryView else { return }
            accessory.backgroundColor = cellBackgroundColor
            accessory.tintColor = cellTextColor
        }
    }
    
    private var menu: Menu?
    private var title: String?

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setTitle("Menu", for: .normal)
    }
    
    public func setMenu(title: String?, items: [CustomStringConvertible], initialSelection: Int, selectionHandler: @escaping ((CustomStringConvertible) -> Void)) {
        guard items.count > 0 && initialSelection >= 0 && initialSelection < items.count else { return }

        self.title = title
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
    }

    public var selectedItem: CustomStringConvertible? {
        return menu?.selectedItem
    }

    fileprivate override func makePopoverViewController() -> UIViewController? {
        guard let menu = self.menu else { return nil }
        return MenuViewController(menu: menu, title: title, tableBackgroundColor: listBackgroundColor, cellBackgroundColor: itemBackgroundColor, cellTextColor: itemTextColor)
    }
}


public class DropDownBarButton: UIBarButtonItem {

    private let _innerButton = DropDownButton()
    fileprivate var innerButton: DropDownButton { return _innerButton }

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

    public var listBackgroundColor: UIColor {
        get { return innerButton.listBackgroundColor }
        set { innerButton.listBackgroundColor = newValue }
    }
    public var itemBackgroundColor: UIColor {
        get { return innerButton.itemBackgroundColor }
        set { innerButton.itemBackgroundColor = newValue }
    }
    public var itemTextColor: UIColor {
        get { return innerButton.itemTextColor }
        set { innerButton.itemTextColor = newValue }
    }

    public var size : CGSize {
        get { return customView!.bounds.size }
        set { customView!.bounds.size = newValue }
    }
}

public class DropDownListBarButton: DropDownBarButton {
    
    public func setList(title: String?, items: [CustomStringConvertible]) {
        innerButton.setList(title: title, items: items)
    }

    private let _innerButton = DropDownListButton()
    fileprivate override var innerButton: DropDownListButton { return _innerButton }
}

public class DropDownMenuBarButton: DropDownBarButton {
    
    public func setMenu(title: String?, items: [CustomStringConvertible], initialSelection: Int, selectionHandler: @escaping ((CustomStringConvertible) -> Void)) {
        innerButton.setMenu(title: title, items: items, initialSelection: initialSelection, selectionHandler: selectionHandler)
    }

    private let _innerButton = DropDownMenuButton()
    fileprivate override var innerButton: DropDownMenuButton { return _innerButton }

    public var selectedItem: CustomStringConvertible? {
        return innerButton.selectedItem
    }
}

