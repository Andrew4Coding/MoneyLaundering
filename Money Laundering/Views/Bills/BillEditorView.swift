//
//  BillEditorView.swift
//  Money Laundering
//

import PhotosUI
import SwiftData
import SwiftUI

/// Create or edit a bill: attach a photo, scan it with Apple Intelligence, then review the
/// items and shared charges.
struct BillEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: BillEditorViewModel
    @State private var photoItem: PhotosPickerItem?
    @State private var isPresentingCamera = false
    @State private var isPresentingImage = false

    init(bill: Bill? = nil) {
        if let bill {
            _viewModel = State(initialValue: BillEditorViewModel(editing: bill))
        } else {
            _viewModel = State(initialValue: BillEditorViewModel())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                imageSection
                scanStatusSection
                detailsSection
                itemsSection
                chargesSection

                Section {
                    BillSummaryCard(totals: viewModel.totals)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Bill" : "New Bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save(context: modelContext) { dismiss() }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .onChange(of: photoItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: data)
                    {
                        viewModel.imageData = ReceiptImage.compressedData(from: image)
                        await autoScanIfNeeded()
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresentingCamera) {
                CameraPicker { data in
                    isPresentingCamera = false
                    if let data {
                        viewModel.imageData = data
                        Task { await autoScanIfNeeded() }
                    }
                }
                .ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $isPresentingImage) {
                if let data = viewModel.imageData {
                    ReceiptViewer(imageData: data) { isPresentingImage = false }
                }
            }
        }
    }

    private func autoScanIfNeeded() async {
        guard viewModel.items.isEmpty else { return }
        await viewModel.runScan()
    }

    @ViewBuilder
    private var imageSection: some View {
        Section("Bill Photo") {
            if let data = viewModel.imageData, let image = UIImage(data: data) {
                Button {
                    isPresentingImage = true
                } label: {
                    HStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("View photo").foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if viewModel.canScan {
                    Button {
                        Task { await viewModel.runScan() }
                    } label: {
                        Label("Rescan Bill", systemImage: "text.viewfinder")
                    }
                    .disabled(viewModel.scanState == .scanning)
                }

                Button("Remove Photo", role: .destructive) {
                    viewModel.imageData = nil
                    photoItem = nil
                }
            } else {
                if CameraPicker.isAvailable {
                    Button {
                        isPresentingCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                }
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
            }
        }
    }

    @ViewBuilder
    private var scanStatusSection: some View {
        switch viewModel.scanState {
        case .idle:
            EmptyView()
        case .scanning:
            Section {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Scanning bill…")
                        .foregroundStyle(.secondary)
                }
            }
        case .done:
            if viewModel.usedHeuristicScan {
                Section {
                    Text("Read the bill directly (no Apple Intelligence) — double-check the items and amounts below.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        case let .failed(message):
            Section {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                if viewModel.canScan {
                    Button("Try Again") { Task { await viewModel.runScan() } }
                }
            }
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Merchant", text: $viewModel.merchant)
            TextField("Note (optional)", text: $viewModel.title)
            DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                .datePickerStyle(.compact)
        }
    }

    private var itemsSection: some View {
        Section("Items") {
            ForEach($viewModel.items) { $item in
                VStack(spacing: 8) {
                    HStack {
                        Button {
                            item.isSelected.toggle()
                        } label: {
                            Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isSelected ? AppTheme.accent : .secondary)
                        }
                        .buttonStyle(.plain)

                        TextField("Item name", text: $item.name)
                    }
                    HStack(spacing: 12) {
                        Stepper("Qty \(item.quantity)", value: $item.quantity, in: 1 ... 99)
                            .fixedSize()
                        Spacer()
                        TextField("Amount", text: $item.amountText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: viewModel.removeItems)

            Button {
                viewModel.addItem()
            } label: {
                Label("Add Item", systemImage: "plus.circle")
            }
        }
    }

    private var chargesSection: some View {
        Section("Charges") {
            LabeledContent("Tax") {
                TextField("0", text: $viewModel.taxText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Service") {
                TextField("0", text: $viewModel.serviceText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Discount") {
                TextField("0", text: $viewModel.discountText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

#Preview {
    BillEditorView()
        .modelContainer(for: [Bill.self, BillItem.self], inMemory: true)
}
