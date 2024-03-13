//
//  ContentView.swift
//  BookListApp
//
//  Created by Rayhan Wilangkara on 2/18/24.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var viewModel = BookListViewModel()
    @State private var showingAddBookView = false
    @State private var showingDeleteView = false
    @State private var currentBookIndex = 0
    @State private var showingSearchAlert = false
    @State private var searchText = ""
    @State private var showingSearchResultAlert = false
    @State private var searchResultMessage = ""
    @State private var showingSearchView = false
    @State private var showingEditView = false

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.books.isEmpty {
                    Text("No books available")
                } else if currentBookIndex < viewModel.books.count {
                    let book = viewModel.books[currentBookIndex]
                    VStack {
                        Text(book.title).font(.headline)
                        Text(book.author).font(.subheadline)
                        Text(book.genre).font(.caption)
                        Text("Price: \(book.price, specifier: "%.2f")").font(.caption)
                    }
                }

                Spacer()
            }
            .navigationBarTitle("Books")
            .navigationBarItems(
                leading: Button("Delete") {
                    showingDeleteView = true
                },
                trailing: Button("Add") {
                    showingAddBookView = true
                }
            )
            .sheet(isPresented: $showingAddBookView) {
                AddBookView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingDeleteView) {
                DeleteBookView(viewModel: viewModel)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Prev") {
                        navigateToPrevious()
                    }
                    .disabled(viewModel.books.isEmpty || currentBookIndex <= 0)
                    Button("Next") {
                        navigateToNext()
                    }
                    .disabled(viewModel.books.isEmpty || currentBookIndex >= viewModel.books.count - 1)
                    Button("Search") {
                        showingSearchAlert = true
                    }
                    .sheet(isPresented: $showingSearchAlert) {
                        SearchView(viewModel: viewModel, currentBookIndex: $currentBookIndex)
                    }
                    Button("Edit") {
                        showingEditView = true
                    }
                    .sheet(isPresented: $showingEditView) {
                        EditBookView(viewModel: viewModel, book: $viewModel.books[currentBookIndex])
                    }
                }
            }
            .alert(isPresented: $showingSearchResultAlert) {
                Alert(title: Text("Search Result"), message: Text(searchResultMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func navigateToPrevious() {
        if currentBookIndex > 0 {
            currentBookIndex -= 1
        }
    }

    private func navigateToNext() {
        if currentBookIndex < viewModel.books.count - 1 {
            currentBookIndex += 1
        }
    }
    private func searchBook() {
        
            let result = viewModel.books.firstIndex { $0.title.lowercased().contains(searchText.lowercased()) }
            
            if let index = result {
                currentBookIndex = index
                searchResultMessage = "Title: \(viewModel.books[index].title)\nAuthor: \(viewModel.books[index].author)\nGenre: \(viewModel.books[index].genre)\nPrice: \(viewModel.books[index].price)"
                showingSearchResultAlert = true
            } else {
                searchResultMessage = "Book not found."
                showingSearchResultAlert = true
            }
        }
}
    
struct EditBookView: View {
    @ObservedObject var viewModel: BookListViewModel
    @Binding var book: Book
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $book.title)
                TextField("Author", text: $book.author)
                TextField("Genre", text: $book.genre)
                TextField("Price", value: $book.price, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                
                Button("Save") {
                    viewModel.updateBook(id: book.id, title: book.title, author: book.author, genre: book.genre, price: book.price)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationBarTitle("Edit Book")
        }
    }
}


struct SearchView: View {
    @ObservedObject var viewModel: BookListViewModel
    @Binding var currentBookIndex: Int
    @State private var searchText = ""
    @State private var showingSearchResultAlert = false
    @State private var searchResultMessage = ""

    var body: some View {
        VStack {
            TextField("Enter the title of the book", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Search") {
                searchBook()
            }
            .padding()
        }
        .alert(isPresented: $showingSearchResultAlert) {
            Alert(title: Text("Search Result"), message: Text(searchResultMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func searchBook() {
        let result = viewModel.books.firstIndex { $0.title.lowercased().contains(searchText.lowercased()) }
        
        if let index = result {
            currentBookIndex = index
            searchResultMessage = "Title: \(viewModel.books[index].title)\nAuthor: \(viewModel.books[index].author)\nGenre: \(viewModel.books[index].genre)\nPrice: \(viewModel.books[index].price)"
        } else {
            searchResultMessage = "Book not found."
        }
        showingSearchResultAlert = true
    }
}

struct BookDetailView: View {
    let book: Book

    var body: some View {
        VStack {
            Text(book.title)
                .font(.title)
            Text(book.author)
                .font(.headline)
            Text(book.genre)
                .font(.subheadline)
            Text("\(book.price, specifier: "%.2f")")
                .font(.subheadline)
        }
        .padding()
    }
}

struct AddBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BookListViewModel
    
    @State private var title = ""
    @State private var author = ""
    @State private var genre = ""
    @State private var price = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("Genre", text: $genre)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                
                Button("Save") {
                    saveBook()
                }
                .disabled(title.isEmpty || author.isEmpty || genre.isEmpty || price.isEmpty)
            }
            .navigationBarTitle("Add New Book", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func saveBook() {
        if let actualPrice = Double(price) {
            viewModel.addBook(title: title, author: author, genre: genre, price: actualPrice)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct DeleteBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BookListViewModel
    
    @State private var titleToDelete = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter Title to Delete", text: $titleToDelete)
                
                Button("Delete") {
                    deleteBook()
                }
                .disabled(titleToDelete.isEmpty)
            }
            .navigationBarTitle("Delete Book", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func deleteBook() {
        viewModel.deleteBook(byTitle: titleToDelete)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    ContentView()
}
