//
//  AmountCalculatorView.swift
//  Money Laundering
//

import SwiftUI

/// Full-page numeric entry for the transaction amount, backed by a small calculator so the
/// user can type expressions like "50000+25000" and see the running total formatted live.
struct AmountCalculatorView: View {
    @Binding var amountText: String

    @State private var viewModel: AmountCalculatorViewModel
    @Environment(\.dismiss) private var dismiss

    private enum Key: Hashable, Identifiable {
        case digit(String)
        case op(AmountCalculatorViewModel.Operator)
        case backspace

        var id: Self { self }
    }

    private let rows: [[Key]] = [
        [.digit("7"), .digit("8"), .digit("9"), .op(.divide)],
        [.digit("4"), .digit("5"), .digit("6"), .op(.multiply)],
        [.digit("1"), .digit("2"), .digit("3"), .op(.subtract)],
        [.digit("0"), .digit("000"), .backspace, .op(.add)]
    ]

    init(amountText: Binding<String>) {
        _amountText = amountText
        _viewModel = State(initialValue: AmountCalculatorViewModel(initialText: amountText.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 0) {
            display
            keypad
        }
        .navigationTitle("Amount")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    amountText = NSDecimalNumber(decimal: viewModel.finalValue).stringValue
                    dismiss()
                }
                .disabled(viewModel.finalValue <= 0)
            }
        }
    }

    private var display: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(viewModel.expressionDisplay.isEmpty ? " " : viewModel.expressionDisplay)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(viewModel.formattedCurrentInput)
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.formattedCurrentInput)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 24)
    }

    private var keypad: some View {
        VStack(spacing: 12) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(rows[rowIndex]) { key in
                        keyButton(for: key)
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.clear()
                } label: {
                    Text("C")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(.bordered)
                .tint(.red)

                Button {
                    viewModel.equals()
                } label: {
                    Text("=")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private func keyButton(for key: Key) -> some View {
        Button {
            tap(key)
        } label: {
            keyLabel(for: key)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
        }
        .buttonStyle(.bordered)
        .tint(tint(for: key))
    }

    @ViewBuilder
    private func keyLabel(for key: Key) -> some View {
        switch key {
        case .digit(let value):
            Text(value).font(.title2.weight(.medium))
        case .op(let op):
            Text(op.rawValue).font(.title2.weight(.semibold))
        case .backspace:
            Image(systemName: "delete.left").font(.title3.weight(.medium))
        }
    }

    private func tint(for key: Key) -> Color {
        switch key {
        case .op: .accentColor
        case .digit, .backspace: .secondary
        }
    }

    private func tap(_ key: Key) {
        switch key {
        case .digit(let value): viewModel.inputDigit(value)
        case .op(let op): viewModel.inputOperator(op)
        case .backspace: viewModel.backspace()
        }
    }
}

#Preview {
    NavigationStack {
        AmountCalculatorView(amountText: .constant(""))
    }
}
