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
        if  userIsInTheMiddleOfTypingNumber {
            if display.text!.rangeOfString(".")  == nil || digit  != "." {
                display.text = display.text! + digit
            }
        } else {
            if digit != "." {
                display.text = digit
                userIsInTheMiddleOfTypingNumber = true
            }
        }
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        if let operation = sender.currentTitle{
            if var result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingNumber = false
        if let result = brain.pushOperand(displayValue){
            displayValue = result
        } else {
            displayValue = 0
        }
    }

    @IBAction func historyAction(sender: UIButton) {
        history.text = history.text! + sender.currentTitle!
    }
    
    
    @IBAction func clear(sender: UIButton) {
        history.text = " "
        display.text = "0"
        //operandStack = []
    }
    
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
        }
    }
}

