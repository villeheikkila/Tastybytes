import SFSafeSymbols
import SwiftUI

struct ProgressButton<LabelView: View>: View {
  private let logger = getLogger(category: "ProgressButton")
  enum ActionOption: CaseIterable {
    case disableButton
    case showProgressView
  }

  let role: ButtonRole?
  var action: () async -> Void
  var actionOptions = Set(ActionOption.allCases)
  @ViewBuilder var label: () -> LabelView

  init(
    role: ButtonRole? = nil,
    action: @escaping () async -> Void,
    actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
    @ViewBuilder label: @escaping () -> LabelView
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
          do {
            try await Task.sleep(nanoseconds: 150_000_000)
            isLoading = true
          } catch {
            logger.info("Timer cancelled")
          }
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

extension ProgressButton where LabelView == Text {
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

extension ProgressButton where LabelView == Label<Text, Image> {
  init(_ title: String, systemImage: String,
       role: ButtonRole? = nil,
       actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
       action: @escaping () async -> Void)
  {
    self.init(role: role, action: action) {
      Label(title, systemImage: systemImage)
    }
  }
}

extension ProgressButton where LabelView == Label<Text, Image> {
  init(_ title: String, systemSymbol: SFSymbol,
       role: ButtonRole? = nil,
       actionOptions _: Set<ActionOption> = Set(ActionOption.allCases),
       action: @escaping () async -> Void)
  {
    self.init(role: role, action: action) {
      Label(title, systemSymbol: systemSymbol)
    }
  }
}
