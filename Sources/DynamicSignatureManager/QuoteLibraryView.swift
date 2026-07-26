import SwiftUI
import DynamicSignatureDomain

struct QuoteLibraryView: View {

    @EnvironmentObject private var model: AppModel
    @State private var searchText = ""
    @State private var editingQuote: Quote?

    private var filteredQuotes: [Quote] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return model.quotes }
        return model.quotes.filter {
            $0.text.localizedCaseInsensitiveContains(trimmed)
                || ($0.author?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search quotes or authors", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding([.horizontal, .top])

            if filteredQuotes.isEmpty {
                emptyState
            } else {
                quoteList
            }

            if let message = model.statusMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    editingQuote = Quote(text: "")
                } label: {
                    Label("Add Quote", systemImage: "plus")
                }

                Button("Import…") {
                    model.importQuotes()
                }

                Button("Export…") {
                    model.exportQuotes()
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
    }

    private var quoteList: some View {
        List {
            ForEach(filteredQuotes) { quote in
                QuoteRow(
                    quote: quote,
                    onToggle: { model.setQuoteEnabled($0, id: quote.id) },
                    onEdit: { editingQuote = quote },
                    onDelete: { model.deleteQuotes(ids: [quote.id]) }
                )
            }
        }
        .listStyle(.inset)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "quote.bubble")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(model.quotes.isEmpty ? "No quotes yet — add one or import a JSON file." : "No quotes match your search.")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct QuoteRow: View {

    let quote: Quote
    let onToggle: (Bool) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Toggle("", isOn: Binding(get: { quote.isEnabled }, set: { onToggle($0) }))
                .labelsHidden()
                .toggleStyle(.checkbox)
                .help("Include this quote in rotation")

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
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .opacity(quote.isEnabled ? 1 : 0.5)

            Spacer()

            Button("Edit", action: onEdit)
                .buttonStyle(.link)
        }
        .padding(.vertical, 2)
        .contextMenu {
            Button("Edit…", action: onEdit)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}

struct QuoteEditorView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var text: String
    @State private var author: String
    @State private var weight: Double
    @State private var isEnabled: Bool

    private let original: Quote
    private let onSave: (Quote) -> Void

    init(quote: Quote, onSave: @escaping (Quote) -> Void) {
        self.original = quote
        self.onSave = onSave
        _text = State(initialValue: quote.text)
        _author = State(initialValue: quote.author ?? "")
        _weight = State(initialValue: quote.weight)
        _isEnabled = State(initialValue: quote.isEnabled)
    }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(original.text.isEmpty ? "New Quote" : "Edit Quote")
                .font(.headline)

            TextEditor(text: $text)
                .font(.body)
                .frame(minHeight: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.3))
                )

            TextField("Author (optional)", text: $author)

            HStack {
                Text("Weight")
                Slider(value: $weight, in: 0.1...5.0)
                Text(weight.formatted(.number.precision(.fractionLength(1))))
                    .monospacedDigit()
                    .frame(width: 32, alignment: .trailing)
            }
            .help("Higher weight makes this quote appear more often")

            Toggle("Enabled", isOn: $isEnabled)

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    var quote = original
                    quote.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedAuthor = author.trimmingCharacters(in: .whitespaces)
                    quote.author = trimmedAuthor.isEmpty ? nil : trimmedAuthor
                    quote.weight = weight
                    quote.isEnabled = isEnabled
                    onSave(quote)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
            }
        }
        .padding(20)
        .frame(width: 420)
    }
}
