import SwiftUI

struct ProgressButton<Label: View>: View {
  enum ActionOption: CaseIterable {
    case disableButton
    case showProgressView
  }

  let role: ButtonRole?
  var action: () async -> Void
  var actionOptions = Set(ActionOption.allCases)
  @ViewBuilder var label: () -> Label

  init(
    role: ButtonRole? = nil,
    action: @escaping () async -> Void,
    actionOptions: Set<ActionOption> = Set(),
    @ViewBuilder label: @escaping () -> Label
  ) {
    self.role = role
    self.action = action
    self.actionOptions = actionOptions
    self.label = label
  }

  @State private var isDisabled = false
  @State private var isLoading = false

  var body: some View {
    Button(role: role, action: { buttonAction() }, label: { buttonLabel })
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

extension ProgressButton where Label == Text {
  init(_ label: String,
       role: ButtonRole? = nil,
       actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
       action: @escaping () async -> Void)
  {
    self.init(role: role, action: action) {
      Text(label)
    }
  }
}

extension ProgressButton where Label == Image {
  init(systemImageName: String,
       role: ButtonRole? = nil,
       actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
       action: @escaping () async -> Void)
  {
    self.init(role: role, action: action) {
      Image(systemName: systemImageName)
    }
  }
}
