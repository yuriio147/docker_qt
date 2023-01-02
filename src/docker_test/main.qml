import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")


    ColumnLayout {
        anchors.centerIn: parent

        Repeater {
            model: 10

            Text {
                text: qsTr("text") + index
            }
        }
    }
}
