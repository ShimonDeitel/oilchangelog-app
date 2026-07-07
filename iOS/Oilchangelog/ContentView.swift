import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: OilchangelogEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "drop.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.accent)
                        Text("No entries yet")
                            .font(Theme.headingFont)
                            .foregroundStyle(Theme.textPrimary)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(Theme.headingFont)
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(Theme.textPrimary.opacity(0.7))
                                    if !entry.mileage.isEmpty {
                                        Text("Mileage: \(entry.mileage)")
                                            .font(.caption)
                                            .foregroundStyle(Theme.accent)
                                    }
                                }
                            }
                            .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                        .listRowBackground(Theme.cardBackground)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Oil Change Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.isAtFreeLimit && !purchases.isPro {
                            showingPaywall = true
                        } else {
                            showingAdd = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add) { entry in
                    if !store.add(entry) {
                        showingAdd = false
                        showingPaywall = true
                    }
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(mode: .edit(entry)) { updated in
                    store.update(updated)
                } onDelete: {
                    store.delete(entry)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }
}

enum EntryFormMode {
    case add
    case edit(OilchangelogEntry)
}

struct EntryFormView: View {
    let mode: EntryFormMode
    var onSave: (OilchangelogEntry) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var field2: String = ""
    @State private var field3: String = ""
    @State private var note: String = ""
    @FocusState private var focusedField: Field?

    enum Field { case title, field2, field3, note }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("titleField")
                        .focused($focusedField, equals: .title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Mileage", text: $field2)
                        .accessibilityIdentifier("field2Field")
                        .focused($focusedField, equals: .field2)
                    TextField("Oil Type", text: $field3)
                        .accessibilityIdentifier("field3Field")
                        .focused($focusedField, equals: .field3)
                    TextField("Note", text: $note)
                        .accessibilityIdentifier("noteField")
                        .focused($focusedField, equals: .note)
                }
                if case .edit = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            onDelete?()
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry: OilchangelogEntry
                        if case .edit(let existing) = mode {
                            entry = existing
                        } else {
                            entry = OilchangelogEntry(title: "")
                        }
                        entry.title = title.isEmpty ? "Untitled" : title
                        entry.date = date
                        entry.mileage = field2
                        entry.oilType = field3
                        entry.note = note
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear {
                if case .edit(let existing) = mode {
                    title = existing.title
                    date = existing.date
                    field2 = existing.mileage
                    field3 = existing.oilType
                    note = existing.note
                }
            }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
}
