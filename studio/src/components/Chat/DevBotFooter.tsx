import '@/styles/components/DevBotFooter.scss';
import { DefaultButton, IconButton, Stack, TextField, makeStyles } from "@fluentui/react";
import { useTranslation } from 'react-i18next';
import React from "react";


interface props {
    disableSend: boolean
    sendMessageToWss: Function
    onFileChange: any
    pluginStoreToggle: Function
    inputText: string
}

const devbotfooterStyles = makeStyles(theme => ({
    inputFieldStack: {
        
    }
}))

export const DevBotFooter = (props: props) => {
    const fileInput = React.createRef<HTMLInputElement>();
    const classStyles = devbotfooterStyles();
    const { t, i18n} = useTranslation();
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


    return (
        <Stack className='devbot-footer'>
            <Stack.Item>
                <Stack horizontal className='button-stack' tokens={{childrenGap: 20}}>
                    <Stack.Item>
                        <input ref={fileInput} accept=".pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .txt, .rtf, .odt" onChange={props.onFileChange} type='file' multiple hidden />
                        <DefaultButton  onClick={() => { window.event?.stopImmediatePropagation(); fileInput?.current?.click(); }} className='primary-button'>{t('devFooter.uploadFiles')}</DefaultButton>
                    </Stack.Item>
                    <Stack.Item>
                        <DefaultButton onClick={() => props.pluginStoreToggle()} className='primary-button'>{t('devFooter.addPlugin')}</DefaultButton>
                    </Stack.Item>
                </Stack>
            </Stack.Item>
            <Stack.Item>
                <Stack className='input-field-stack'>
                    <Stack.Item>
                        <TextField 
                            maxLength={200000}
                            value={message}
                            onKeyUp={(e) => { 
                                    if (props.disableSend) { return; }
                                    if (e.key === 'Enter') {
                                        props.sendMessageToWss(message);
                                        setMessage('');
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
                                    onClick={() => { if (props.disableSend) { return; } props.sendMessageToWss(message); setMessage('')  }}
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