import TipKit

struct NameTagTip: Tip {
    var title: Text {
        Text("Share your profile")
    }

    var message: Text? {
        Text("Connect with others by sharing your name tag")
    }

    var asset: Image? {
        Image(systemSymbol: .qrcodeViewfinder)
    }
}
