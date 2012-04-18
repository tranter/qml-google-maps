import QtQuick 1.0
import QtWebKit 1.0
import ICS 1.0

//import com.nokia.meego 1.0
import com.nokia.symbian 1.1

Window {
    id: contentArea

    //property bool initialized: false

    anchors {
        fill: parent
    }

    PageStack {
        id: stack
        anchors.fill: parent
    }
    Component.onCompleted: {
        console.log("onCompleted")
        stack.push(Qt.resolvedUrl("MainPage.qml"));
    }
}


