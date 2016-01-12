//
//  ViewController.swift
//  Calculator
//
//  Created by Kate Arapova on 27.09.15.
//  Copyright (c) 2015 Kate Arapova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingNumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingNumber {
            if display.text!.rangeOfString(".")  == nil || digit  != "." {
                display.text = display.text! + digit
            }
        } else {
            userIsInTheMiddleOfTypingNumber = true
            if digit != "." {
                display.text = digit
                userIsInTheMiddleOfTypingNumber = true
            }
        }
    }

    @IBAction func operate(sender: UIButton) {
        if let operation = sender.currentTitle{
            if userIsInTheMiddleOfTypingNumber {
                enter()
            }
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                // error
                displayValue = nil
            }
        }
    }
    
    @IBAction func saveVariable(sender: UIButton) {
        if let variable = sender.currentTitle!.characters.last{
            brain.setVariable("\(variable)", operand: displayValue)
            if let result = brain.evaluate() {
                displayValue = result
            } else {
                // error
                displayValue = nil
            }
        }
        userIsInTheMiddleOfTypingNumber = false
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        if let result = brain.pushOperand(sender.currentTitle) {
            displayValue = result
        } else {
            // erorr
            displayValue = nil
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingNumber = false
        if let result = brain.pushOperand(displayValue){
            displayValue = result
        } else {
            // error
            displayValue = nil
        }
    }

    @IBAction func clear(sender: UIButton) {
        displayValue = nil
        history.text = " "
        userIsInTheMiddleOfTypingNumber = false
        brain.clearOps()
    }
    
    var displayValue: Double? {
        get{
            var description: String {
                return display.text!
            }
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set{
            if let t = newValue {
                display.text = "\(t)"
            } else {
                display.text = " "
            }
            history.text = "\(brain.description) = "
        }
    }
}

