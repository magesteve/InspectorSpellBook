# InspectorSpellBook

[![Swift](https://img.shields.io/badge/Swift-5-blue.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/os-macOS-blue.svg)](https://apple.com/mac)
[![Xcode](https://img.shields.io/badge/Xcode-12-blue.svg)](https://developer.apple.com/xcode)
[![SPM](https://img.shields.io/badge/SPM-Compatible-blue)](https://swift.org/package-manager)
[![MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Swift Package to provide standard left & right side panels (commonly used as Inspectors) for Macintosh App Development (Cocoa).

The program can display a normal window, with associated menus/toolbaritem/button, so that tapping on the right button has a side view animated in, while the main view compresses to make room for the side panel. Tapping the item closes this panel.  Any number of panels can be attached to any Inspector, and two Inspectors (left & right) can be attached to a window.

This is a great User Interface to display Inspector for the window!

## Installation

### Requirements

- MacOS 10.15
- Swift 5
- Xcode 11
- NSViewController based window.

### Repository

  https://github.com/magesteve/InspectorSpellBook
  
## Inspector Magic

## Interface Builder Requirment

More than any previous SpellBook, this requires a bit of setup with the Target app's Storyboard to work. Since the Inspector slide in from the side, the main view of the viewcontroller must resize for this. Thus the main  view can not be the NSViewController content view, but instead must be a NSView on top of the Content View. This main view must had constraints on all four sized, matching the View to the Super View. The constaint constant must be zero (no indent).   The code will automatically resize the contraints when needed.

SImilarly, the a view that will slide in and out must also be on top of the content view.  It't top and bottom must be constrained to the Convent View top and bottom.  The horizontal size must be set to the requested Inspector size.  Lastly one of the edges (trainling edge for right views, Leading Edge for left view) must be set to the Content View edge.  Thus originally the slider appears to be on the slide it will slide in on.

Lastly the Constaint for both main view and the side must must be organized so first element of the constraint must be the content view, while the second element must be the view on the content view.

## Coding Requirement

At this point, one or two Inspectors can be added to the ViewController as a variable.  The initalizer must set if it is a left or right inspector, the View Controller the Inspector is attached to, the main view (not the Content view), and the side view.  Usually the initializing of the Inspector is done in the viewDidLoad() function of the View Controller, after the Storyboard has loaded the VIews.

Next for each panel to add to the Inspector, call the add(ident: viewController:) function of the Inspector. This call needs to have a unique ident (string) for the Inspector (it won't be displayed anywhere), and a View Controller. The View of the Controller will be resized to place within the Side view before it is animated in. Any number of panels can be added to the Inspector in this manner.

Next add Menus/ToolbarItem/Button to press to display the Inspector.  The Action for each item should call the tap(ident:) function of the Inspector, passing the ident of the panel previously set. If the Inspector is not open, the side view will slide in with the new panel being shown. If that panel is already open, then the panel will close. If the side view is open, but another panel is showing, the panel will change to the correct one.

## Demo App

Sample code using this SpellBook can be found in the open-source Cocoa App [CocoaGrimoire](https://github.com/magesteve/CocoaGrimoire). Other SpellBooks by the author are also demonstrated there.

## License

CocoaSpellBook is available as open source under the terms of the [MIT](https://github.com/magesteve/InspectorSpellBook/blob/main/LICENSE) License.
