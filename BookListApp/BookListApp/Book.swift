//
//  Book.swift
//  BookListApp
//
//  Created by Rayhan Wilangkara on 2/18/24.
//


import Foundation

struct Book: Identifiable {
    let id = UUID()
    var title: String
    var author: String
    var genre: String
    var price: Double
}
