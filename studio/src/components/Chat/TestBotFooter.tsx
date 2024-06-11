import { DefaultButton, IconButton, Stack, TextField, makeStyles } from "@fluentui/react";
import React from "react";


interface props {
    disableSend: boolean
    sendMessageToWss: Function
}

const testBotFooterStyles = makeStyles(theme => ({
    primaryButton: {
        background: '#5694FF',
        color: '#fff',
        ":hover": {
            background: '#4d85e5',
            color: '#fff'
        }
    },
    buttonStack: {
        width: '100%',
        display: 'flex',
        justifyContent: 'center',
        padding: 5,
        paddingBottom: 10
    },
    inputFieldStack: {
        justifyItems: 'center',
        alignItems: 'center',
        justifyContent: 'space-around',
        '.ms-TextField': {
            width: '350px',
            maxWidth: '-webkit-fill-available !important'
        }
    },
    wrapperStack: {
        padding: 10
    }
}))

export const testBotFooter = (props: props) => {
    const fileInput = React.createRef<HTMLInputElement>();
    const classStyles = testBotFooterStyles();
    const [message, setMessage] = React.useState('');
    return (
        <Stack className={classStyles.wrapperStack}>
            <Stack.Item>
                <Stack className='input-field-stack'>
                    <Stack.Item>
                        <TextField 
                            maxLength={2000}
                            value={message}
                            onKeyUp={(e) => { 
                                    if (props.disableSend) { return; }
                                    if (e.key === 'Enter') {
                                        props.sendMessageToWss(message);
                                        setMessage('');
                                    } 
                                }
                            }
                            multiline={true}
                            resizable={false}
                            onChange={(e, value) => { setMessage(value || '') }}
                            type="text" placeholder="Type your message here..."
                            onRenderSuffix={() => {
                               return (<IconButton 
                                    onClick={() => { 
                                        if (props.disableSend) { return; }
                                        props.sendMessageToWss(message);
                                        setMessage('')  
                                    }}
                                    iconProps={{'iconName': 'Send'}} title="Emoji" ariaLabel="Emoji" disabled={props.disableSend} />) 
                            }}
                            />
                    </Stack.Item>
                </Stack>

            </Stack.Item>
        </Stack>
    )
}

export default testBotFooter;