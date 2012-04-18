import QtQuick 1.0
import QtWebKit 1.0
import ICS 1.0

//import com.nokia.meego 1.0
import com.nokia.symbian 1.0

Page {
    //width: 360
    //height: 360

    SettingsManager {
        id: settingsManager
    }



    WebView {
        id: webView
        anchors { left: parent.left; right: parent.right; bottom: lineEdit.top; top: parent.top }
        //url: "qrc:/html/qml/google_maps.html"
        html: settingsManager.htmlString

        onLoadFinished: {
            console.log("onLoadFinished");
            busy_indicator.running = false;
            busy_indicator.visible = false;
        }

        onLoadStarted: {
            console.log("onLoadStarted");
            busy_indicator.running = true;
            busy_indicator.visible = true;
        }

        BusyIndicator {
            id: busy_indicator;
            running: false
            width:  100;
            height: 100;
            anchors.centerIn:  parent;
            visible: false
        }



        javaScriptWindowObjects:
            QtObject {
            id: windowObject
            WebView.windowObjectName: "qml"
            property int zoom: 15;
            property string mapTypeId: "google.maps.MapTypeId.ROADMAP";
            property double lat: 0.0
            property double lng: 0.0
        }
    }

    ListModel {
        id: mapTypeModel
        ListElement { modelData: "RoadMap";      type: "google.maps.MapTypeId.ROADMAP"}
        ListElement { modelData: "Satellite";    type: "google.maps.MapTypeId.SATELLITE"}
        ListElement { modelData: "Hybrid";       type: "google.maps.MapTypeId.HYBRID"}
        ListElement { modelData: "Terrain";      type: "google.maps.MapTypeId.TERRAIN"}
    }

    SelectionDialog {
        id: selectionDialog
        titleText: "Select type of Map"
        selectedIndex: -1

        model: mapTypeModel

        onSelectedIndexChanged: {
            console.log("Selected index = ", selectedIndex);
            if(-1 < selectedIndex && selectedIndex < model.count)
                changeMapType(model.get(selectedIndex).type);
        }
    }

    function changeMapType(type)
    {
        webView.evaluateJavaScript("window.qml.zoom=map.zoom;" +
                                   "window.qml.lat=map.center.lat(); window.qml.lng=map.center.lng();"
                                   );
        console.log("Zoom = ", windowObject.zoom, "mapTypeId = ", windowObject.mapTypeId);
        console.log("lat, lng", windowObject.lat, windowObject.lng);
        settingsManager.zoom = windowObject.zoom;
        settingsManager.mapTypeId = type;
        var north = settingsManager.lat;
        var east  = settingsManager.lng;
        if(windowObject.lat != 0)
        {
            north = windowObject.lat;
            east = windowObject.lng;
        };

        //settingsManager.lat = north;
        //settingsManager.lng = east;

        //change map type
        var str = "map.setMapTypeId("+ settingsManager.mapTypeId + ");"
//        console.log(str);
        webView.evaluateJavaScript(str);

        //adding marker
        str =
                "if (marker != null) marker.setMap(null);" +
                "marker = new google.maps.Marker({" +
                "position: map.center," +
                "map: map," +
                "title: \"Entered Location here\"});" +
                "var contentString = \"Entered Location\";" +
                "var infowindow = new google.maps.InfoWindow({ content: \"My location\" });" +
                "google.maps.event.addListener(marker, 'click', function() {" +
                "infowindow.open(map,marker);});"
        //        console.log(str);
        webView.evaluateJavaScript(str);
    }

    Button {
        id: mapTypeButton
        anchors { top: parent.top; right: parent.right }
        text: "Props"
        width:  120
        height: 40

        onClicked: {
            console.log("Props clicked")
            selectionDialog.selectedIndex = -1;
            selectionDialog.open();
        }
    }


    TextField {
        id: lineEdit
        anchors { bottom: parent.bottom; left: parent.left; right: goButton.left }
        height: 40;
        text: ""
    }
    Button {
        id: goButton
        anchors { bottom: parent.bottom; right: parent.right }
        text: "Go";
        width: 120; height: 40
        onClicked: {
            console.log("Go clicked", lineEdit.text)

            if( lineEdit.text.length == 0 ) {
                console.log("text is empty")
                return
            }

            webView.evaluateJavaScript("window.qml.zoom=map.zoom;" +
                                       "if(map.mapTypeId == google.maps.MapTypeId.ROADMAP) window.qml.mapTypeId =\"google.maps.MapTypeId.ROADMAP\";" +
                                       "if(map.mapTypeId == google.maps.MapTypeId.SATELLITE) window.qml.mapTypeId =\"google.maps.MapTypeId.SATELLITE\";" +
                                       "if(map.mapTypeId == google.maps.MapTypeId.HYBRID) window.qml.mapTypeId =\"google.maps.MapTypeId.HYBRID\";" +
                                       "if(map.mapTypeId == google.maps.MapTypeId.TERRAIN) window.qml.mapTypeId =\"google.maps.MapTypeId.TERRAIN\";" +
                                       "window.qml.lat=map.center.lat(); window.qml.lng=map.center.lng()"
                                       );
            console.log("Zoom = ", windowObject.zoom, "mapTypeId = ", windowObject.mapTypeId);
            console.log("lat, lng", windowObject.lat, windowObject.lng);
            settingsManager.zoom = windowObject.zoom;
            settingsManager.mapTypeId = windowObject.mapTypeId;

            var client = new XMLHttpRequest();
            client.onreadystatechange = function() {
                // in case of network errors this might not give reliable results
                if(client.readyState == XMLHttpRequest.DONE)
                {
                    //console.log("readyState", client.readyState, client.responseText);
                    var result = eval('(' + client.responseText + ')');

                    var placeMarks = result["Placemark"];
                    if(placeMarks.length == 0)
                    {
                        console.log("No placeMarks")
                        return;
                    }

                    console.log("placeMarks.length", placeMarks.length)

                    var east  = placeMarks[0]["Point"]["coordinates"][0];
                    var north = placeMarks[0]["Point"]["coordinates"][1];
                    console.log("east, north", east, north);

                    settingsManager.lat = north;
                    settingsManager.lng = east;


                    //go to new map position
                    var str =  "var myLatLng = new google.maps.LatLng(" + north + "," + east+ ");"+
                            "map.setCenter(myLatLng);";
//                    console.log(str);
                    webView.evaluateJavaScript(str);


                    //adding marker
                    str =
                            "if (marker != null) marker.setMap(null);" +
                            "marker = new google.maps.Marker({" +
                            "position: map.center," +
                            "map: map," +
                            "title: \"Entered Location here\"});" +
                            "var contentString = \"Entered Location\";" +
                            "var infowindow = new google.maps.InfoWindow({ content: \"My location\" });" +
                            "google.maps.event.addListener(marker, 'click', function() {" +
                            "infowindow.open(map,marker);});"
//                    console.log(str);
                    webView.evaluateJavaScript(str);

                    busy_indicator.running = false;
                    busy_indicator.visible = false;

                }
            }
            client.open("GET", "http://maps.google.com/maps/geo?q=" + lineEdit.text+ "&key=" + settingsManager.getApiKey() + "&output=json&oe=utf8&sensor=false");
            busy_indicator.running = true;
            busy_indicator.visible = true;
            client.send();
        }
    }

}
