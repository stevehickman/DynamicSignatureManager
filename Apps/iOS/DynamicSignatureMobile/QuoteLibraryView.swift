import SwiftUI
import UniformTypeIdentifiers
import DynamicSignatureDomain

struct QuoteLibraryView: View {

    @EnvironmentObject private var model: MobileAppModel
    @State private var searchText = ""
    @State private var editingQuote: Quote?
    @State private var showingImporter = false
    @State private var exportDocument: QuotesJSONDocument?

    private var filteredQuotes: [Quote] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return model.quotes }
        return model.quotes.filter {
            $0.text.localizedCaseInsensitiveContains(trimmed)
                || ($0.author?.localizedCaseInsensitiveContains(trimmed) ?? false)
                || $0.tags.contains { $0.localizedCaseInsensitiveContains(trimmed) }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredQuotes.isEmpty {
                    emptyState
                } else {
                    quoteList
                }
            }
            .navigationTitle("Quotes")
            .searchable(text: $searchText, prompt: "Quotes, authors, or tags")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editingQuote = Quote(text: "")
                    } label: {
                        Label("Add Quote", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Button("Import…") { showingImporter = true }
                        Button("Export…") {
                            if let data = model.exportData() {
                                exportDocument = QuotesJSONDocument(data: data)
                            }
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $editingQuote) { quote in
                QuoteEditorView(quote: quote) { edited in
                    if model.quotes.contains(where: { $0.id == edited.id }) {
                        model.updateQuote(edited)
                    } else {
                        model.addQuote(edited)
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json]
            ) { result in
                importQuotes(result)
            }
            .fileExporter(
                isPresented: Binding(
                    get: { exportDocument != nil },
                    set: { if !$0 { exportDocument = nil } }
                ),
                document: exportDocument,
                contentType: .json,
                defaultFilename: "quotes"
            ) { _ in }
        }
    }

    private var quoteList: some View {
        List {
            if let message = model.statusMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(filteredQuotes) { quote in
                QuoteRow(quote: quote)
                    .contentShape(Rectangle())
                    .onTapGesture { editingQuote = quote }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) {
                            model.deleteQuotes(ids: [quote.id])
                        }
                        Button("Edit") { editingQuote = quote }
                    }
                    .swipeActions(edge: .leading) {
                        Button(quote.isEnabled ? "Disable" : "Enable") {
                            model.setQuoteEnabled(!quote.isEnabled, id: quote.id)
                        }
                        .tint(quote.isEnabled ? .orange : .green)
                    }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            model.quotes.isEmpty ? "No quotes yet" : "No matches",
            systemImage: "quote.bubble",
            description: Text(
                model.quotes.isEmpty
                    ? "Add a quote or import a JSON file."
                    : "No quotes match your search."
            )
        )
    }

    private func importQuotes(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            do {
                model.importQuotes(from: try Data(contentsOf: url))
            } catch {
                model.reportImportFailure(error)
            }
        case .failure(let error):
            model.reportImportFailure(error)
        }
    }
}

private struct QuoteRow: View {

    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(quote.text)
                .lineLimit(3)
            HStack(spacing: 8) {
                if let author = quote.author, !author.isEmpty {
                    Text("— \(author)")
                }
                if quote.usageCount > 0 {
                    Text("Used \(quote.usageCount)×")
                }
                if quote.weight != 1.0 {
                    Text("Weight \(quote.weight.formatted(.number.precision(.fractionLength(0...1))))")
                }
                if !quote.tags.isEmpty {
                    Label(
                        quote.tags.sorted().joined(separator: ", "),
                        systemImage: SeasonalTags.seasonalTags(of: quote).isEmpty ? "tag" : "calendar"
                    )
                    .lineLimit(1)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .opacity(quote.isEnabled ? 1 : 0.5)
    }
}

struct QuoteEditorView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var text: String
    @State private var author: String
    @State private var tagsText: String
    @State private var weight: Double
    @State private var isEnabled: Bool

    private let original: Quote
    private let onSave: (Quote) -> Void

    init(quote: Quote, onSave: @escaping (Quote) -> Void) {
        self.original = quote
        self.onSave = onSave
        _text = State(initialValue: quote.text)
        _author = State(initialValue: quote.author ?? "")
        _tagsText = State(initialValue: quote.tags.sorted().joined(separator: ", "))
        _weight = State(initialValue: quote.weight)
        _isEnabled = State(initialValue: quote.isEnabled)
    }

    private var editedTags: Set<String> {
        Set(
            tagsText.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                .filter { !$0.isEmpty }
        )
    }

    private var seasonalTagsEntered: [String] {
        editedTags.intersection(SeasonalTags.recognized).sorted()
    }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quote") {
                    TextField("Quote text", text: $text, axis: .vertical)
                        .lineLimit(3...8)
                    TextField("Author (optional)", text: $author)
                }

                Section {
                    TextField("Tags, comma-separated (optional)", text: $tagsText)
                        .textInputAutocapitalization(.never)
                } footer: {
                    if seasonalTagsEntered.isEmpty {
                        Text("Seasonal tags like \u{201C}winter\u{201D}, \u{201C}december\u{201D}, or \u{201C}christmas\u{201D} limit the quote to that time of year. Other tags are just for organizing.")
                    } else {
                        Text("Seasonal: \(seasonalTagsEntered.joined(separator: ", ")) — this quote only appears at the matching time of year.")
                    }
                }

                Section {
                    HStack {
                        Text("Weight")
                        Slider(value: $weight, in: 0.1...5.0)
                        Text(weight.formatted(.number.precision(.fractionLength(1))))
                            .monospacedDigit()
                            .frame(width: 32, alignment: .trailing)
                    }
                    Toggle("Enabled", isOn: $isEnabled)
                } footer: {
                    Text("Higher weight makes this quote appear more often.")
                }
            }
            .navigationTitle(original.text.isEmpty ? "New Quote" : "Edit Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var quote = original
                        quote.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedAuthor = author.trimmingCharacters(in: .whitespaces)
                        quote.author = trimmedAuthor.isEmpty ? nil : trimmedAuthor
                        quote.tags = editedTags
                        quote.weight = weight
                        quote.isEnabled = isEnabled
                        onSave(quote)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

/// Wraps the exported quote-library JSON for `fileExporter`.
struct QuotesJSONDocument: FileDocument {

    static let readableContentTypes: [UTType] = [.json]

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
