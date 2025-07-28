//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by William White on 02.06.2025.
//
import UIKit
import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
