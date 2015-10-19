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
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        switch operation {
            case "×": performOperation {$0 * $1}
            case "÷": performOperation {$1 / $0}
            case "+": performOperation {$0 + $1}
            case "−": performOperation {$1 - $0}
            case "√": performOperation { sqrt($0) }
            case "sin": performOperation { sin($0) }
            case "cos": performOperation { cos($0) }
            case "∏": performOperation { M_PI }
            default: break
        }
    }
    

    @IBAction func historyAction(sender: UIButton) {
        history.text = history.text! + sender.currentTitle!
    }
    
    
    @IBAction func clear(sender: UIButton) {
        history.text = " "
        display.text = "0"
        operandStack = []
        userIsInTheMiddleOfTypingNumber = false
    }
    
    func performOperation(operation: (Double, Double) -> Double){
        if operandStack.count >= 2{
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: Double -> Double){
        if operandStack.count >= 1{
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }

    private func performOperation(operation: () -> Double){
        if operandStack.count >= 2{
            displayValue = operation()
            enter()
        }
    }
    
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingNumber = false
        operandStack.append(displayValue)
        //print("operantStack = \(operandStack)")
    }
    
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingNumber = false
        }
    }
}

