import TipKit

struct NameTagTip: Tip {
    var title: Text {
        Text("profile.nameTag.tip.share")
    }

    var message: Text? {
        Text("profile.nameTag.tip.description")
    }

    var asset: Image? {
        Image(systemName: "qrcode.viewfinder")
    }
}
