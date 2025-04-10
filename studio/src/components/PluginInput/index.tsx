import '@/styles/components/publishModal.scss';
import { DefaultButton, Label, Stack, TextField, Dropdown } from '@fluentui/react';
import React from 'react';

interface props {
    pluginErrorCodes: any,
    pluginOutputVariableNames: any,
    sendPluginValues: Function
}

export const PluginInput = (props: props) => {
    const errorCodesList = props.pluginErrorCodes ?? [];
    const errorCodes = errorCodesList.map((x, i) => ({'key': x, 'text': x}));

    if (errorCodes.length > 0) {
        errorCodes[0].selected = true;
    }
    const [selectedErrorCode, setSelectedErrorCode] = React.useState(0);

    const setChoice = (e, o, i) => {
        setSelectedErrorCode(i);
    }

    let valueDict = {}
    for (var idx = 0; idx < props.pluginOutputVariableNames.length; idx++) {
        valueDict[idx] = React.useState('');
    }

    const sendFromData = () => {
        let formData = {}
        formData["type"] = "plugin"
        formData["vars"] = {}
        formData["vars"]["plugin_response"] = {}

        if (errorCodes.length > 0)
            formData["vars"]["plugin_response"]["plugin_status"] = errorCodes[selectedErrorCode].key;
        
        let simpleVersion = "Return Status : " + errorCodes[selectedErrorCode].key + "\n"
        formData["vars"]["plugin_response"]["plugin_output"] = {}
        for (var k in valueDict) {
            formData["vars"]["plugin_response"]["plugin_output"][props.pluginOutputVariableNames[k]] = valueDict[k][0];
            simpleVersion += props.pluginOutputVariableNames[k]
            simpleVersion += " : "
            simpleVersion += valueDict[k][0]
            simpleVersion += "\n"
        }
        const stringVersion = JSON.stringify(formData) + "\xa1" + simpleVersion;
        props.sendPluginValues(stringVersion);
    }

    return (
        <Stack className='content publish-modal-container'>
            <Stack.Item>
                <Stack>
                    <Stack.Item>
                        <Dropdown
                            label="Please select the plugin error code"
                            options={errorCodes}
                            onChange={setChoice} />
                    </Stack.Item>
                </Stack>
                {props.pluginOutputVariableNames.map((vname: string, index: number) => (
                    <Stack vertical>
                        <Stack.Item>
                            <Label>{vname}</Label>
                        </Stack.Item>
                        <Stack.Item>
                            <TextField
                                onChange={(e, value) => { valueDict[index][1](value || '') }}
                                value={valueDict[index][0]} />
                        </Stack.Item>
                    </Stack>
                ))
                }
                <Stack>
                    <Stack.Item>
                        <DefaultButton onClick={() => sendFromData()}>Submit</DefaultButton>
                    </Stack.Item>
                </Stack>
            </Stack.Item>
        </Stack>
    );
}

export default PluginInput;