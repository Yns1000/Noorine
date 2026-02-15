import WidgetKit
import SwiftUI

@main
struct NoorineWidgetBundle: WidgetBundle {
    var body: some Widget {
        WordOfDayWidget()
        StreakWidget()
        NoorineWidgetLiveActivity()
        NoorineStreakLiveActivity()
    }
}
