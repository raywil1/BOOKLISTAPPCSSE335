//
//  BookListViewModel.swift
//  BookListApp
//
//  Created by Rayhan Wilangkara on 2/18/24.
//

import Foundation

class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []
    
    func addBook(title: String, author: String, genre: String, price: Double) {
        let newBook = Book(title: title, author: author, genre: genre, price: price)
        books.append(newBook)
    }
    
    func deleteBook(byTitle title: String) {
        books.removeAll { $0.title == title }
    }
    
    func searchBook(byTitleOrGenre titleOrGenre: String) -> Book? {
        return books.first { $0.title == titleOrGenre || $0.genre == titleOrGenre }
    }
    
    func updateBook(id: UUID, title: String, author: String, genre: String, price: Double) {
        if let index = books.firstIndex(where: { $0.id == id }) {
            books[index].title = title
            books[index].author = author
            books[index].genre = genre
            books[index].price = price
        }
    }
}
