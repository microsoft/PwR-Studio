import '@/styles/components/publishModal.scss';
import { DefaultButton, Label, Stack, TextField } from '@fluentui/react';
import React from 'react';

interface props {
    variableNames: any,
    sendVariableValues: Function
}

export const FormInput = (props: props) => {
    let valueDict = {}
    for (var idx = 0; idx < props.variableNames.length; idx++) {
        valueDict[idx] = React.useState('');
    }
    
    const sendFromData = () => {
        let formData = {}
        formData["type"] = "form"
        formData["vars"] = {}
        
        let simpleVersion = ""
        for (var k in valueDict) {
            formData["vars"][props.variableNames[k]] = valueDict[k][0];
            simpleVersion += props.variableNames[k]
            simpleVersion += " : "
            simpleVersion += valueDict[k][0]
            simpleVersion += "\n"
        }
        const stringVersion = JSON.stringify(formData) + "\xa1" + simpleVersion;
        props.sendVariableValues(stringVersion);
    }

    return (
        <Stack className='content publish-modal-container'>
            <Stack.Item>
                {props.variableNames.map((vname: string, index: number) => (
                    <Stack vertical>
                        <Stack.Item>
                            <Label>{vname}</Label>
                        </Stack.Item>
                        <Stack.Item>
                            <TextField 
                                onChange={(e, value) => { valueDict[index][1](value || '') }}
                                value={valueDict[index][0]}/>
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

export default FormInput;