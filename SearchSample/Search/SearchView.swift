import Combine
import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchModel

    var body: some View {
        NavigationView {
            List {
                SearchBar(text: $viewModel.query)
                ForEach(viewModel.animes, id: \.self) { anime in
                    VStack(alignment: .leading) {
                        Text(anime.title)
                        Text(anime.synopsis)
                            .font(.footnote)
                    }
                }
            }
            .navigationBarTitle("Anime Search")
            .alert(item: $viewModel.errorMessage) {
                Alert(title: Text("Error"), message: Text($0), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// Copied from: https://www.appcoda.com/swiftui-search-bar/
struct SearchBar: View {
    @Binding var text: String

    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField("Search for anime by title", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    struct PreviewSearchService: SearchService {
        func search(query _: String) -> AnyPublisher<[Anime], Error> {
            Just([Anime(airing: true, malId: 0, url: "https://animepage.com", imageURL: "https://images.com/image.png", title: "Anime 1", synopsis: "A synopsis of this anime", rated: "R")])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    static var previews: some View {
        SearchView(viewModel: SearchModel(PreviewSearchService()))
    }
}
