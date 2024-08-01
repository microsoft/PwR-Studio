import '@/styles/components/DevBotFooter.scss';
import { DefaultButton, IconButton, Stack, TextField, Text, makeStyles } from "@fluentui/react";
import React from "react";
import '../../styles/selectedPlugin.css';

interface props {
    disableSend: boolean
    sendMessageToWss: Function
    onFileChange: any
    pluginStoreToggle: Function
    inputText: string
    selectedPlugins: Set<any>
    setSelectedPlugins: React.Dispatch<React.SetStateAction<Set<any>>>
}

const devbotfooterStyles = makeStyles(theme => ({
    inputFieldStack: {
        
    }
}))

export const DevBotFooter = (props: props) => {
    const fileInput = React.createRef<HTMLInputElement>();
    const classStyles = devbotfooterStyles();
    const [message, setMessage] = React.useState('');

    React.useEffect(() => { 
        if (props.inputText) {
            if (message.includes(props.inputText)) {
                return;
            }
            if (message) {
                setMessage(message + (props.inputText || ''));
            } else {
                setMessage(props.inputText);
            }
        }
    }, [props.inputText]);

    const sendAndReset = () => {
        if (props.disableSend) { return; }
        props.sendMessageToWss(message);
        setMessage('');
        props.setSelectedPlugins(new Set());
    };

    return (
        <Stack className='devbot-footer'>
            <Stack.Item>
                <Stack horizontal className='button-stack' tokens={{childrenGap: 20}}>
                    <Stack.Item>
                        <input ref={fileInput} accept=".pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .txt, .rtf, .odt" onChange={props.onFileChange} type='file' multiple hidden />
                        <DefaultButton  onClick={() => { window.event?.stopImmediatePropagation(); fileInput?.current?.click(); }} className='primary-button'>Upload Files</DefaultButton>
                    </Stack.Item>
                    <Stack.Item>
                        <DefaultButton onClick={() => props.pluginStoreToggle()} className='primary-button'>Add Plugin</DefaultButton>
                    </Stack.Item>
                </Stack>
            </Stack.Item>
            <Stack.Item>
                <Stack horizontal tokens={{ childrenGap: 10 }}>
                    {[...props.selectedPlugins].map((plugin, index) => (
                        <Stack.Item key={index} className='selected-plugin-box'>
                            <Text>{plugin.name}</Text>
                            <IconButton iconProps={{ iconName: 'Cancel' }} onClick={() => props.setSelectedPlugins(prevPlugins => {
                                const updatedPlugins = new Set(prevPlugins);
                                updatedPlugins.delete(plugin);
                                return updatedPlugins;
                            })} />
                        </Stack.Item>
                    ))}
                </Stack>
                <Stack className='input-field-stack'>
                    <Stack.Item>
                        <TextField 
                            maxLength={200000}
                            value={message}
                            onKeyUp={(e) => { 
                                    if (props.disableSend) { return; }
                                    if (e.key === 'Enter') {
                                        sendAndReset();
                                    } 
                                }
                            }
                            onChange={(e, value) => { setMessage(value || '') }}
                            type="text"
                            placeholder="Type your message here..."
                            multiline={true}
                            resizable={false}
                            onRenderSuffix={() => {
                               return (<IconButton 
                                    disabled={props.disableSend}
                                    onClick={sendAndReset}
                                    iconProps={{'iconName': 'Send'}} title="Emoji" ariaLabel="Emoji" />) 
                            }}
                            />
                    </Stack.Item>
                </Stack>

            </Stack.Item>
        </Stack>
    )
}

export default DevBotFooter;