//
//  ViewController.swift
//  ControllerCollectionView
//
//  Created by Chris Budro on 3/9/16.
//  Copyright © 2016 Vectorform. All rights reserved.
//

import UIKit

//MARK: Datasource Protocol

@objc public protocol ControllerCollectionViewDataSource: class {
    func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, controllerForItemAtIndexPath indexPath: NSIndexPath) -> CollectionChildViewController
    func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, numberOfItemsInSection section: Int) -> Int
    optional func numberOfSections(controllerCollectionView: ControllerCollectionViewController) -> Int
}

//MARK: Delegate Protocol

@objc public protocol ControllerCollectionViewDelegate: UIScrollViewDelegate {
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, willDisplayController controller: CollectionChildViewController, forItemAtIndexPath indexPath: NSIndexPath)
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, didEndDisplayingController controller: CollectionChildViewController, forItemAtIndexPath indexPath: NSIndexPath)
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, shouldSelectControllerAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, didSelectControllerAtIndexPath indexPath: NSIndexPath)
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, shouldDeselectControllerAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, didDeselectControllerAtIndexPath indexPath: NSIndexPath)
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, shouldHighlightControllerAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, didHighlightControllerAtIndexPath indexPath: NSIndexPath)
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, didUnhighlightControllerAtIndexPath indexPath: NSIndexPath)
    
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint
    optional func controllerCollectionView(controllerCollectionView: ControllerCollectionViewController, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
}

//MARK: ControllerCollectionViewController


/**
    The ControllerCollectionViewController is a collection view for view controllers.

    It is a wrapper around a UICollectionView and can be used very similarly to a regular collection view.  
    The view controller containment is handled internally for all collection view controllers. 
    The controller incorporates reusable view controllers reliant on a datasource object.
*/
public class ControllerCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    //Generic reuse identifier for the underlying container cell
    private let cellReuseIdentifier = "Cell"
    
    private let collectionView: UICollectionView
    private var viewControllersByIndexPath = [NSIndexPath: CollectionChildViewController]()
    private let reuseManager = ControllerReuseManager()
    
    
    /**
     The object that provides the data for the Controller Collection
     
     The data source must adopt the ControllerCollectionViewDataSource protocol. 
     The controller collection view maintains a weak reference to the data source object.
     */
    public weak var dataSource: ControllerCollectionViewDataSource?
    
    /**
     The object that acts as the delegate for the controller collection view
     this includes the scroll view delegate
     
    The delegate must adopt the ControllerCollectionViewDelegate protocol.  
    To act as the delegate of the scroll view it must also adopt the UIScrollViewDelegate protocol
    */
    public weak var delegate: ControllerCollectionViewDelegate? {
        didSet {
            scrollViewDelegate = delegate
        }
    }
    private weak var scrollViewDelegate: UIScrollViewDelegate?
    
    //MARK: Collection View Pass Through Properties
    
    public var contentView: UICollectionView {
        return collectionView
    }
    
    public var contentOffset: CGPoint {
        get {
            return collectionView.contentOffset
        }
        set {
            collectionView.contentOffset = newValue
        }
    }
    
    public var collectionViewLayout: UICollectionViewLayout {
        get {
            return collectionView.collectionViewLayout
        }
        set {
            collectionView.collectionViewLayout = newValue
        }
    }
    
    public var pagingEnabled: Bool {
        get {
            return collectionView.pagingEnabled
        }
        set {
            collectionView.pagingEnabled = newValue
        }
    }
    
    public var showsHorizontalScrollIndicator: Bool {
        get {
            return collectionView.showsHorizontalScrollIndicator
        }
        set {
            collectionView.showsHorizontalScrollIndicator = newValue
        }
    }
    
    public var showsVerticalScrollIndicator: Bool {
        get {
            return collectionView.showsVerticalScrollIndicator
        }
        set {
            collectionView.showsVerticalScrollIndicator = newValue
        }
    }
    
    public var backgroundView: UIView? {
        get {
            return collectionView.backgroundView
        }
        set {
            collectionView.backgroundView = newValue
        }
    }
    
    public var backgroundColor: UIColor? {
        get {
            return collectionView.backgroundColor
        }
        set {
            collectionView.backgroundColor = newValue
        }
    }
    
    public var allowsSelection: Bool {
        get {
            return collectionView.allowsSelection
        }
        set {
            collectionView.allowsSelection = newValue
        }
    }
    
    public var allowsMultipleSelection: Bool {
        get {
            return collectionView.allowsMultipleSelection
        }
        set {
            collectionView.allowsMultipleSelection = newValue
        }
    }

    //MARK: Init

    public init() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionLayout)

        super.init(nibName: nil, bundle: nil)
        
        collectionView.collectionViewLayout = defaultCollectionViewLayout()
        setupCollectionView()
    }
    
    public init(collectionViewLayout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        
        super.init(nibName: nil, bundle: nil)
        
        setupCollectionView()
    }

    required public init?(coder aDecoder: NSCoder) {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionLayout)
        
        super.init(coder: aDecoder)
        
        collectionView.collectionViewLayout = defaultCollectionViewLayout()
        setupCollectionView()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        reuseManager.clearReuseQueue()
        removeUnusedChildViewControllers()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        visibleControllers().forEach { (visibleController) in
            visibleController.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        visibleControllers().forEach { (visibleController) in
            visibleController.endAppearanceTransition()
        }
    }

    //MARK: Reusable Controller Registration
    
    func registerClass(cellClass: CollectionChildViewController.Type, forReuseIdentifier reuseIdentifier: String) {
        reuseManager.registerClass(cellClass, forReuseIdentifier: reuseIdentifier)
        
    }
    
    func registerClass(cellClass: CollectionChildViewController.Type, withNibName nibName: String, forReuseIdentifier reuseIdentifier: String) {
        reuseManager.registerClass(cellClass, withNibName: nibName, forReuseIdentifier: reuseIdentifier)
    }

    //MARK: Data Source
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections?(self) ?? 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfItems = dataSource?.controllerCollectionView(self, numberOfItemsInSection: section) {
            return numberOfItems
        }
        return 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ControllerCollectionContainerCell
        if let viewController = dataSource?.controllerCollectionView(self, controllerForItemAtIndexPath: indexPath) {
            cell.controllerView = viewController.view
            setIndexPath(indexPath, forViewController: viewController)
        }
        return cell
    }
    
    private func setIndexPath(indexPath: NSIndexPath, forViewController viewController: CollectionChildViewController) {
        viewControllersByIndexPath[indexPath] = viewController
        viewController.indexPath = indexPath
    }
    
    //MARK: Delegate
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let viewController = viewControllersByIndexPath[indexPath] {
            delegate?.controllerCollectionView?(self, willDisplayController: viewController, forItemAtIndexPath: indexPath)
                viewController.beginAppearanceTransition(true, animated: true)
                viewController.endAppearanceTransition()
        }
    }

    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let viewController = viewControllersByIndexPath[indexPath] {
            delegate?.controllerCollectionView?(self, didEndDisplayingController: viewController, forItemAtIndexPath: indexPath)
            viewController.beginAppearanceTransition(false, animated: true)
            viewController.endAppearanceTransition()
            
            reuseManager.enqueueReusableController(viewController, withIdentifier: viewController.reuseIdentifier)
            viewControllersByIndexPath.removeValueForKey(indexPath)
        }
    }
    
    //MARK: Controller Selection/Highlight/Focus Delegate
    
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return delegate?.controllerCollectionView?(self, shouldSelectControllerAtIndexPath: indexPath) ?? false
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.controllerCollectionView?(self, didSelectControllerAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return delegate?.controllerCollectionView?(self, shouldDeselectControllerAtIndexPath: indexPath) ?? false
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.controllerCollectionView?(self, didDeselectControllerAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return delegate?.controllerCollectionView?(self, shouldHighlightControllerAtIndexPath: indexPath) ?? false
    }
    
    public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.controllerCollectionView?(self, didHighlightControllerAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.controllerCollectionView?(self, didUnhighlightControllerAtIndexPath: indexPath)
    }
    
    //TODO: Add support for focus engine

    public func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        if let transitionLayout = delegate?.controllerCollectionView?(self, transitionLayoutForOldLayout: fromLayout, newLayout: toLayout) {
            return transitionLayout
        } else {
            return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let targetContentOffset = delegate?.controllerCollectionView?(self, targetContentOffsetForProposedContentOffset: proposedContentOffset) {
            return targetContentOffset
        } else {
            return proposedContentOffset
        }
    }
    
    //MARK: Dequeue Controller
    
    public func dequeueViewControllerWithReuseIdentifier(reuseID: String) -> CollectionChildViewController {
        if let viewController = reuseManager.dequeueViewControllerWithReuseIdentifierIfAvailable(reuseID) {
            return viewController
        } else {
            let newController = reuseManager.newViewControllerWithReuseIdentifier(reuseID)
            newController.willMoveToParentViewController(self)
            addChildViewController(newController)
            newController.didMoveToParentViewController(self)
            
            return newController
        }
    }

    //MARK: ScrollViewDelegate Passthrough
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

    public func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? false
    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    //MARK: Helper Methods
    
    public func addCollectionToParentController(parentController: UIViewController) {
        parentController.addChildViewController(self)
        parentController.view.addSubview(view)
        didMoveToParentViewController(parentController)
    }
    
    public func controllerAtIndexPath(indexPath: NSIndexPath) -> CollectionChildViewController? {
        return viewControllersByIndexPath[indexPath]
    }
    
    public func indexPathForController(childViewController: CollectionChildViewController) -> NSIndexPath? {
        return childViewController.indexPath
    }
    
    public func visibleControllers() -> [CollectionChildViewController] {
        return Array(viewControllersByIndexPath.values)
    }
    
    public func indexPathsForVisibleControllers() -> [NSIndexPath] {
        return Array(viewControllersByIndexPath.keys)
    }
    
    public func indexPathsForSelectedControllers() -> [NSIndexPath]? {
        return collectionView.indexPathsForSelectedItems()
    }
    
    public func selectControllerAtIndexPath(indexPath: NSIndexPath, animated: Bool, scrollPosition: UICollectionViewScrollPosition) {
        collectionView.selectItemAtIndexPath(indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    public func deselectControllerAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: animated)
    }
    
    public func indexPathForControllerAtPoint(point: CGPoint) -> NSIndexPath? {
        return collectionView.indexPathForItemAtPoint(point)
    }
    
    public func scrollToControllerAtIndexPath(indexPath: NSIndexPath, atScrollPosition scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: animated)
    }
    
    private func enqueueAllVisibleControllers() {
        for visibleController in visibleControllers() {
            reuseManager.enqueueReusableController(visibleController, withIdentifier: visibleController.reuseIdentifier)
        }
    }
    
    private func clearAllVisibleControllers() {
        viewControllersByIndexPath.removeAll()
    }

    
    //TODO: Following methods need to be tested
    
    public func reloadData() {

        enqueueAllVisibleControllers()
        clearAllVisibleControllers()
        
        collectionView.reloadData()
    }

    //TODO: Following methods need to be finished.  marked private until complete
    
    private func reloadSections(sections: NSIndexSet) {
        collectionView.reloadSections(sections)
    }
    
    private func reloadControllersAtIndexPaths(indexPaths: [NSIndexPath]) {
        collectionView.reloadItemsAtIndexPaths(indexPaths)
    }
    
    private func insertControllersAtIndexPaths(indexPaths: [NSIndexPath]) {
        collectionView.insertItemsAtIndexPaths(indexPaths)
    }
    
    private func deleteControllersAtIndexPaths(indexPaths: [NSIndexPath]) {
        collectionView.deleteItemsAtIndexPaths(indexPaths)
    }
    
    private func moveControllerAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        collectionView.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath)
    }
    
    //MARK: Collection View Pass through methods
    
    public func startInteractiveTransitionToCollectionViewLayout(layout: UICollectionViewLayout, completion: UICollectionViewLayoutInteractiveTransitionCompletion?) -> UICollectionViewTransitionLayout {
        return collectionView.startInteractiveTransitionToCollectionViewLayout(layout, completion: completion)
    }
    
    public func finishInteractiveTransition() {
        collectionView.finishInteractiveTransition()
    }
    
    public func cancelInteractiveTransition() {
        collectionView.cancelInteractiveTransition()
    }
    
    public func setCollectionViewLayout(layout: UICollectionViewLayout, animated: Bool) {
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }
    
    public func setCollectionViewLayout(layout: UICollectionViewLayout, animated: Bool, completion: ((Bool) -> Void)?) {
        collectionView.setCollectionViewLayout(layout, animated: animated, completion: completion)
    }
    
    private func removeUnusedChildViewControllers() {
        for childViewController in childViewControllers {
            if let childViewController = childViewController as? CollectionChildViewController {
                if !viewControllersByIndexPath.values.contains(childViewController) {
                    childViewController.willMoveToParentViewController(nil)
                    childViewController.removeFromParentViewController()
                }
            }
        }
    }

    //MARK: Collection View Setup
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        guard let itemSize = delegate?.controllerCollectionView?(self, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath) else {
            return view.bounds.size
        }
        
        return itemSize
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        setCollectionViewConstraints()
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        collectionView.registerClass(ControllerCollectionContainerCell.self, forCellWithReuseIdentifier: self.cellReuseIdentifier)
    }
    
    private func defaultCollectionViewLayout() -> UICollectionViewLayout {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.Vertical;
        collectionLayout.minimumInteritemSpacing = 0.0;
        collectionLayout.minimumLineSpacing = 0.0;

        return collectionLayout
    }
    
    private func setCollectionViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: collectionView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: collectionView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        
        [topConstraint, leftConstraint, rightConstraint, bottomConstraint].forEach() { $0.active = true }
    }
    
    override public func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return false
    }
}

