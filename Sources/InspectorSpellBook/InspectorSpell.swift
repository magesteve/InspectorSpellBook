//
//  InspectorStruct.swift
//  InspectorSpellBook
//
//  Created by Steve Sheets on 2/7/21.
//

import Foundation
import Cocoa

// MARK: - Protocol

/// Optopma; Protocol for controllers to manage Inspector on View Controller
public protocol InspectorControllerProtocol: NSViewController {
    
    /// Required inspector for protocol for optional left panel
    var inspectorLeft: InspectorSpell? { get }
    
    /// Required inspector for protocol for optional right panel
    var inspectorRight: InspectorSpell? { get }

}

// MARK: - Enums

/// State of the Inspector (Start unable to open/close)
public enum InspectorState: Int {
    case start = 0
    case closed
    case open
}

/// Kind of Inspector (Orientation)
public enum InspectorKind: Int {
    case right = 0
    case left
}

// MARK: - Structures

/// Information regarding a pane (with View Controller) that can be displayed in the Inspector. Includes Indentity & TabViewItem.
public struct InspectorPane {

    // MARK: - Variables
    
    /// Identity of pane (unique string)
    public var ident: String
    
    /// View Controller (with View) to place in Inspector.
    public var viewController: NSViewController
    
    /// TabViewItem of pane.
    public var item: NSTabViewItem
    
    // MARK: - Lifecycle
    init(ident: String, viewController: NSViewController, item: NSTabViewItem) {
        self.ident = ident
        self.viewController = viewController
        self.item = item
    }
}

// MARK: - InspectorSpell Class

public class InspectorSpell {
    
    // MARK: - Variables
    
    // Majority of these should not be accessed directly.
    
    public var listPane: [InspectorPane] = []
    public var size: CGFloat = 0.0
    public var delta: CGFloat = 0.0

    public var kind: InspectorKind = .right
    public var state: InspectorState = .start
    public var currentPane: String = ""
    public var mainEdgeConstraint: NSLayoutConstraint?
    public var sideEdgeConstraint: NSLayoutConstraint?

    public weak var viewController: NSViewController?
    public weak var mainView: NSView?
    public weak var contentView: NSView?
    public weak var sideView: NSTabView?

    public var isValid: Bool { state !=  .start}
    
    // MARK: - Lifecycle
    
    /// Init for Inspecter
    /// - Parameters:
    ///   - kind: InspectorKind showing orientation
    ///   - viewController: NSViewController that Inspector will attach to
    ///   - mainView: NSView main view (not content view), that is pinned with constraints on content view.
    ///   - sideView: NSView side view to slide, that is pinned with constraints on content view.
    public init(kind: InspectorKind = .right, viewController: NSViewController, mainView: NSView, sideView: NSTabView) {
        var foundMainEdgeConstraint: NSLayoutConstraint?
        var foundSideConstraint: NSLayoutConstraint?

        let contentView = viewController.view

        for constraint in contentView.constraints {
            if kind == .left {
                if (constraint.firstItem as? NSView == contentView) && (constraint.firstAttribute == NSLayoutConstraint.Attribute.leading) && (constraint.secondAttribute == NSLayoutConstraint.Attribute.leading) {
                    if (constraint.secondItem as? NSView == mainView) {
                        foundMainEdgeConstraint = constraint
                    }
                    if (constraint.secondItem as? NSView == sideView) {
                        foundSideConstraint = constraint
                    }
                }
            }
            else if kind == .right {
                if (constraint.firstItem as? NSView == contentView) && (constraint.firstAttribute == NSLayoutConstraint.Attribute.trailing) && (constraint.secondAttribute == NSLayoutConstraint.Attribute.trailing) {
                    if (constraint.secondItem as? NSView == mainView) {
                        foundMainEdgeConstraint = constraint
                    }
                    if (constraint.secondItem as? NSView == sideView) {
                        foundSideConstraint = constraint
                    }
                }
            }
        }
        
        guard let mainEdgeConstraint = foundMainEdgeConstraint, let sideEdgeConstraint = foundSideConstraint  else { return }

        state = .closed
        
        self.viewController = viewController
        self.contentView = contentView
        self.mainView = mainView
        self.sideView = sideView
        self.mainEdgeConstraint = mainEdgeConstraint
        self.sideEdgeConstraint = sideEdgeConstraint
        self.size = sideView.frame.width
        self.delta = kind == .left ? size : -size
        self.kind = kind

        sideEdgeConstraint.constant = delta
        self.contentView?.layoutSubtreeIfNeeded()
    }
    
    // MARK: - Public Functions

    /// Change Inspectr pane to given pane
    public func change(pane:InspectorPane) {
        self.sideView?.selectTabViewItem(pane.item)
        currentPane = pane.ident
    }
    
    /// Add a view controller with given identity as a new pane.
    public func add(ident: String, viewController: NSViewController) {
        guard isValid else { return }
        
        let item = NSTabViewItem(identifier: ident)
        item.view = viewController.view
        self.sideView?.addTabViewItem(item)

        let pane = InspectorPane(ident: ident, viewController: viewController, item: item)
        listPane.append(pane)
        
        if listPane.count==1 {
            change(pane: pane)
        }
    }
    
    /// Find pane with given identity and return it.
    public func findPane(ident: String) -> InspectorPane {
        for pane in listPane {
            if pane.ident==ident {
                return pane
            }
        }
        
        return listPane[0]
    }
    
    /// Open Pane with given identity.  Animate open if needed.
    public func open(ident: String) {
        guard isValid, listPane.count>0 else { return }
        
        let newPane = findPane(ident: ident)
        
        if state == .closed {
            if currentPane != newPane.ident {
                change(pane:newPane)
            }
            
            NSAnimationContext.runAnimationGroup({context in
                context.duration = 0.5
                context.allowsImplicitAnimation = true
              
                mainEdgeConstraint?.constant = -delta
                sideEdgeConstraint?.constant = 0.0
                
                self.contentView?.layoutSubtreeIfNeeded()
              
            }, completionHandler:nil)
            
            state = .open
        }
        else if state == .open {
            if currentPane != newPane.ident {
                change(pane:newPane)
            }
        }
    }
    
    /// Animate close the pane if open.
    public func close() {
        guard isValid, listPane.count>0 else { return }
        
        if state == .open {
            NSAnimationContext.runAnimationGroup({context in
                context.duration = 0.5
                context.allowsImplicitAnimation = true

                mainEdgeConstraint?.constant = 0.0
                sideEdgeConstraint?.constant = delta

                self.contentView?.layoutSubtreeIfNeeded()
            }, completionHandler:nil)

            state = .closed
       }
    }
    
    /// Tap the pane with given identity. If open to that pane, close it. If closed, open it. If other pane open, change to new pane.
    public func tap(ident: String) {
        guard isValid, listPane.count>0 else { return }
        
        if state == .closed {
            open(ident: ident)
        }
        else if state == .open {
            let newPane = findPane(ident: ident)
            
            if currentPane == newPane.ident {
                close()
            }
            else {
                change(pane:newPane)
            }
        }
   }

}
