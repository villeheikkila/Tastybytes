import SwiftUI

struct ProgressButton<Label: View>: View {
  var action: () async -> Void
  var actionOptions = Set(ActionOption.allCases)
  @ViewBuilder var label: () -> Label

  @State private var isDisabled = false
  @State private var isLoading = false

  var body: some View {
    Button(action: { buttonAction() }, label: { buttonLabel })
      .disabled(isDisabled)
  }

  private func buttonAction() {
    if actionOptions.contains(.disableButton) {
      isDisabled = true
    }

    Task {
      var progressViewTask: Task<Void, Error>?
      if actionOptions.contains(.showProgressView) {
        progressViewTask = Task {
          try await Task.sleep(nanoseconds: 150_000_000)
          isLoading = true
        }
      }
      await action()
      progressViewTask?.cancel()
      isDisabled = false
      isLoading = false
    }
  }

  private var buttonLabel: some View {
    HStack {
      label()
      if isLoading {
        ProgressView()
          .padding(.leading, 10)
      }
    }
  }
}

extension ProgressButton {
  enum ActionOption: CaseIterable {
    case disableButton
    case showProgressView
  }
}

extension ProgressButton where Label == Text {
  init(_ label: String,
       actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
       action: @escaping () async -> Void)
  {
    self.init(action: action) {
      Text(label)
    }
  }
}

extension ProgressButton where Label == Image {
  init(systemImageName: String,
       actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
       action: @escaping () async -> Void)
  {
    self.init(action: action) {
      Image(systemName: systemImageName)
    }
  }
}
