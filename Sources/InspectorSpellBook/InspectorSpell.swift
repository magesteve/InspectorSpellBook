//
//  InspectorStruct.swift
//  InspectorSpellBook
//
//  Created by Steve Sheets on 2/7/21.
//

import Foundation
import Cocoa

// MARK: Protocol

/// Optopma; Protocol for controllers to manage Inspector on View Controller
public protocol InspectorControllerProtocol: NSViewController {
    
    /// Required inspector for protocol for optional left panel
    var inspectorLeft: InspectorSpell? { get }
    
    /// Required inspector for protocol for optional right panel
    var inspectorRight: InspectorSpell? { get }

}

// MARK: Enums

public enum InspectorState: Int {
    case start = 0
    case closed
    case open
}

public enum InspectorKind: Int {
    case right = 0
    case left
}

// MARK: Structures

public struct InspectorPane {
    public var ident: String
    public var viewController: NSViewController
    public var item: NSTabViewItem
    
    init(ident: String, viewController: NSViewController, item: NSTabViewItem) {
        self.ident = ident
        self.viewController = viewController
        self.item = item
    }
}

// MARK: InspectorSpell Class

public class InspectorSpell {
    
    private var listPane: [InspectorPane] = []
    private var size: CGFloat = 0.0
    private var delta: CGFloat = 0.0

    private var kind: InspectorKind = .right
    private var state: InspectorState = .start
    private var currentPane: String = ""
    private var mainEdgeConstraint: NSLayoutConstraint?
    private var sideEdgeConstraint: NSLayoutConstraint?

    private weak var viewController: NSViewController?
    private weak var mainView: NSView?
    private weak var contentView: NSView?
    private weak var sideView: NSTabView?

    public var isValid: Bool { state !=  .start}
    
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
    
    public func change(pane:InspectorPane) {
        self.sideView?.selectTabViewItem(pane.item)
    }
    
    public func add(ident: String, viewController: NSViewController) {
        guard isValid else { return }
        
        let item = NSTabViewItem(identifier: ident)
        item.view = viewController.view
        self.sideView?.addTabViewItem(item)

        let pane = InspectorPane(ident: ident, viewController: viewController, item: item)
        listPane.append(pane)
        
        if listPane.count==1 {
            currentPane = pane.ident

            change(pane: pane)
        }
    }
    
    private func findPane(ident: String) -> InspectorPane {
        for pane in listPane {
            if pane.ident==ident {
                return pane
            }
        }
        
        return listPane[0]
    }
    
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
