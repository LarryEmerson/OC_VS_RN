/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, {Component} from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    View,
    NativeModules,
    NativeEventEmitter,
    TouchableOpacity,
    Alert,
    ListView,
} from 'react-native';
var NativeBridge = NativeModules.OCvsRN;
const NativeModule = new NativeEventEmitter(NativeBridge);
export default class OC_VS_RN extends Component {
    constructor() {
        super();
        this.state = {
            uniqueID: undefined,
            docList: new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}).cloneWithRows([]),
            musicStatus: undefined,
            showDocList: false,
        }
    }

    componentWillUnmount() {
        this.NativeModule.remove();
    }

    componentDidMount() {
        let context = this;
        NativeModule.addListener(
            'fetchUUID',
            (data) => {
                context.setState({
                    uniqueID: data,
                })
            }
        );
        NativeModule.addListener(
            'docListSendToRN',
            (data) => {
                context.setState({
                    docList: new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}).cloneWithRows(data),
                })
            }
        );

        NativeModule.addListener(
            'musicStatusSendToRN',
            (data) => {
                context.setState({
                    musicStatus: data,
                })
            }
        );
        NativeBridge.fetchUUID()
        NativeBridge.ocFuncFetchDocList()
    }

    render() {
        let context = this;
        return (
            <View style={styles.screen}>
                <View style={styles.navigation}>
                    <Text style={styles.navigationTitle}>
                        React Native VS IOS
                    </Text>
                </View>
                <Text style={styles.text}>设备唯一号</Text>
                <Text style={styles.text}>{context.state.uniqueID}</Text>
                <TouchableOpacity
                    onPress={() => {
                        NativeBridge.ocFuncPlayMusic()
                    }}>
                    <Text style={styles.text}>
                        Play Music
                    </Text>
                </TouchableOpacity>
                <TouchableOpacity
                    onPress={() => {
                        NativeBridge.ocFuncPlayOrPause()
                    }}>
                    <Text style={styles.text}>
                        {parseInt(context.state.musicStatus) == 1 ? "暂停" : "播放"}
                    </Text>
                </TouchableOpacity>
                <TouchableOpacity
                    onPress={() => {
                        context.setState({
                            showDocList: !context.state.showDocList
                        })
                    }}>
                    <Text style={styles.text}>
                        Open Doc
                    </Text>
                </TouchableOpacity>
                <ListView
                    dataSource={
                        context.state.showDocList ?
                            context.state.docList :
                            new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2}).cloneWithRows([])
                    }
                    renderRow={(rowData) => {
                        return <TouchableOpacity
                            style={styles.listContainer}
                            onPress={
                                () => {
                                    NativeBridge.ocFuncOpenDoc(rowData)
                                }
                            }
                        >
                            <Text
                                style={styles.listText}
                            >{rowData}</Text>
                        </TouchableOpacity>
                    }}
                    enableEmptySections={true}
                />
            </View>
        );
    }
}

const styles = StyleSheet.create({
    screen: {
        flex: 1,
        backgroundColor: '#F5FCFF',
    },
    navigation: {
        height: 64,
        justifyContent: 'center',
        backgroundColor: '#eeeeee',
    },
    navigationTitle: {
        fontSize: 18,
        textAlign: 'center',
        marginTop: 20
    },

    text: {
        marginTop: 10,
        fontSize: 14,
        textAlign: 'center'
    },
    listContainer: {
        height: 40,
        justifyContent: 'center',
        backgroundColor: '#fefefe',
        borderBottomWidth: 1,
        borderBottomColor: '#eeeeee',
    },
    listText: {
        fontSize: 13,
        textAlign: 'center',
    }
});

AppRegistry.registerComponent('OC_VS_RN', () => OC_VS_RN);
