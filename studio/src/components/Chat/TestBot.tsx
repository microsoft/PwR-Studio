import React from "react";
import useWebSocket, { ReadyState } from "react-use-websocket";
import { APIHost, WebSocketHost } from "./../../constants";
import { Icon, Spinner, SpinnerSize, Stack, makeStyles, mergeStyles } from "@fluentui/react";
import { appInsights } from './../../applicationInsightsService';
import TypingLoader from "./TypingLoader";
import { sendRequest } from '../../api';
import TestBotFooter from "./TestBotFooter";
import { useId } from '@fluentui/react-hooks';


interface props {
    id: string | undefined,
    token: any,
    userId: any,
    setOnlineState: Function,
    resetChat: bool,
    resetChatToggle: Function
}

const testBotStyles = makeStyles(theme => ({
    chat: {
        height: '100%',
        overflowY: 'scroll',
        display: 'flex',
        flex: '1',
        flexDirection: 'column-reverse'
    },
    message: {
        width: '75%',
        padding: '10px',
        margin: '10px',
        borderRadius: '10px',
    },
    agent: {
        background: '#AFD8FF',
        color: '#000'
    },
    plugin: {
        background: '#C9CCCF',
        color: '#000'
    },
    input: {
        alignSelf: 'flex-end',
        backgroundColor: '#f0949e',
        borderStyle: 'dashed',
        borderWidth: '1px',
        borderColor: '#ea95bc',
    },
    user: {
        alignSelf: 'flex-end',
        background: '#CDC2FF',
    },
    noBackground: {
        backgroundColor: 'none',
        margin: 0,
        padding: 0
    },
    debug: {
        borderStyle: 'dashed',
        backgroundColor: '#dff6dd'
    },
    thoughtIcon: {
        color: 'rgb(73, 130, 5)',
        fontWeight: 'bold',
        fontSize: '18px',
        lineHeight: '24px',
        padding: 5
    },
    footerStack: {
        borderTop: '2px solid #bfbfbf',
    }

}))

const TestBot = (props: props) => {

    const classes = testBotStyles();
    const [messages, addMessages] = React.useState<any>([]);
    const [showLoader, setShowLoader] = React.useState<boolean>(false);
    const classUser = mergeStyles(classes.message, classes.user);
    const classInput = mergeStyles(classes.message, classes.input);
    const classAgent = mergeStyles(classes.message, classes.agent);
    const classPlugin = mergeStyles(classes.message, classes.plugin);
    const userTypes = ["instruction", "feedback"]
    const noBackground = mergeStyles(classes.message, classes.noBackground)
    const debugClass = mergeStyles(classes.message, classes.debug);
    const chatContainerRef = React.createRef<HTMLDivElement>();
    const [wrapperHeight, setWrapperHeight] = React.useState('300px');
    const [disableSend, setDisableSend] = React.useState(false);
    const [callBackMode, setCallBackMode] = React.useState(false);

    const botRestartmessage = "_reset_chat_"

    const {
        getWebSocket,
        readyState,
        sendJsonMessage,
        lastJsonMessage,
    } = useWebSocket(`${WebSocketHost}/projects/${props.id}/output`, {
        onOpen: () => console.log('opened'),
        shouldReconnect: (closeEvent) => true,
    });

    const scrollChatToBottom = () => {
        if (chatContainerRef.current) {
            chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight
        }
    }

     React.useEffect(() => {
        if (lastJsonMessage !== null) {
            if (lastJsonMessage.type === 'start') {
                setShowLoader(true);
            }
            if (lastJsonMessage.type === 'end' || lastJsonMessage.type === 'error') {
                setShowLoader(false);
                setDisableSend(false);
            }
            if (lastJsonMessage.type === 'thought' && lastJsonMessage.message.trim() === 'event') {
                setCallBackMode(true);
            }
            if (lastJsonMessage.type === 'thought' && lastJsonMessage.message.trim() === 'input') {
                setCallBackMode(false);
            }
            addMessages((messages: any) => [lastJsonMessage, ...messages])
            scrollChatToBottom();
        }
    }, [lastJsonMessage, addMessages]);
    
    React.useEffect(() => {
        if (readyState === ReadyState.OPEN) {
            props.setOnlineState(true)
        } else {
            props.setOnlineState(true)
        }
    }, [readyState])

    const getClassNames = (messageType: string, message: string) => {
        if (['thought', 'error'].includes(messageType)) {
            return noBackground
        }
        if (messageType === 'debug') {
            return debugClass
        }
        if (message.indexOf('\xa1') > -1) {
            return classInput
        }
        if (userTypes.includes(messageType)) {
            return classUser
        } else if (message.startsWith('##plugin')) {
		    return classPlugin
		} else {
            return classAgent
        }
    }

    const chatId = useId('testbot')
    const footerId = useId('testfooter')

    const resizeObserver = React.useRef<ResizeObserver>(new ResizeObserver((entries: ResizeObserverEntry[]) => {
        window.requestAnimationFrame(() => {
            const container = document.getElementById(chatId);
            const footer = document.getElementById(footerId);
            let height = wrapperHeight;
            if (container) {
                if (footer) {
                    height = window.innerHeight - container.getBoundingClientRect().top - footer.getBoundingClientRect().height - 2 + 'px';
                } else {
                    height = window.innerHeight - container.getBoundingClientRect().top + 'px';
                }
            }
            setWrapperHeight(height)
        });

    }));


    React.useLayoutEffect(() => {
        window.requestAnimationFrame(() => {
            const container = document.getElementById(chatId);
            const footer = document.getElementById(footerId);
            let height = wrapperHeight;
            if (container) {
                if (footer) {
                    height = window.innerHeight - container.getBoundingClientRect().top - footer.getBoundingClientRect().height - 2 + 'px';
                } else {
                    height = window.innerHeight - container.getBoundingClientRect().top + 'px';
                }
            }
            setWrapperHeight(height)
        });
    }, [])

    const resizedContainerRef = React.useCallback((container: HTMLDivElement) => {
        if (container !== null) {
            resizeObserver.current.observe(container);
        } else {
            if (resizeObserver.current)
                resizeObserver.current.disconnect();
        }
    }, []);

    const sendMessageToWss = (message: string) => {
        if (message.trim() === "") {
            alert("Please type an instruction")
            return
        }
        let toSendMsg: any = { type: "instruction", message: message }
        if (callBackMode) {
            toSendMsg.message = "callback\xa1" + message;
        }
        addMessages((messages: any) => [toSendMsg, ...messages])
        sendRequest({
            url: `${APIHost}/log`,
            accessToken: props.token,
            method: "POST",
            headers: {
                "Content-Type": 'application/json'
            },
            body: JSON.stringify({
                name: `userChatDev`,
                project_id: props.id,
                user_id: props.userId,
                timestamp: new Date().toISOString(),
                data: toSendMsg
            })
        })
        appInsights && appInsights.trackEvent({ name: 'userChat', properties: { projectId: props.id, chatType: 'dev', data: toSendMsg } })
        sendJsonMessage(toSendMsg)
        setDisableSend(true);
    }

    const getMessage = (msg:string) => {
        if (msg.indexOf('\xa1') > -1) {
            return msg.split('\xa1')[1];
        }
        return msg;
    }

    React.useEffect(() => {
        if (props.resetChat) {
            sendMessageToWss(botRestartmessage);
            props.resetChatToggle(false);
        }
    }, [props.resetChat]);

    return (
        <Stack id={chatId}>
            <Stack.Item>
                <div className={classes.chat} style={{ height: wrapperHeight, overflowY: 'auto'}} ref={resizedContainerRef}>
                    {showLoader &&
                        <div>
                            <TypingLoader />
                        </div>}
                        {messages ? messages.map((message: any, index: string) => (
                                // <div key={crypto.randomUUID()}>
                                <>
                                    {message.message.trim() !== '' && !['representation_edit', 'files'].includes(message.type) && !(message.type === 'thought' && ['input', 'event'].includes(message.message.trim())) && message.message.trim() !== botRestartmessage  &&
                                        <div
                                            key={crypto.randomUUID()}
                                            className={getClassNames(message.type, message.message)}
                                        >
                                            <Stack>
                                                <Stack.Item>
                                                    <Stack horizontal={['thought', 'error'].includes(message.type) ? true : false}>
                                                        <Stack.Item>
                                                            {message.type === 'thought' && <Icon iconName="Accept" className={classes.thoughtIcon} />}
                                                            {message.type === 'error' && <Icon iconName="StatusErrorFull" style={{ color: 'red' }} className={classes.thoughtIcon} />}
                                                        </Stack.Item>
                                                        <Stack.Item>    
                                                            <div style={{ whiteSpace: 'pre-line' }}>
                                                                {message.type === 'output' ? 
                                                                <div dangerouslySetInnerHTML={{ __html: getMessage(message.message) }} />
                                                                : getMessage(message.message)}
                                                            </div>
                                                        </Stack.Item>
                                                    </Stack>
                                                </Stack.Item>
                                            
                                            </Stack>
                                        </div>}
                                        </>
                            )) :
                                <Spinner size={SpinnerSize.large}></Spinner>

                            }
                </div>
            </Stack.Item>
            <Stack.Item id={footerId} className={classes.footerStack}>
                <TestBotFooter disableSend={disableSend} sendMessageToWss={sendMessageToWss} />
            </Stack.Item>
        </Stack>
    )
}

export default TestBot;