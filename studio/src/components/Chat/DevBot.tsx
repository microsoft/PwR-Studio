import '@/styles/components/DevBot.scss';
import React from 'react';
import useWebSocket, { ReadyState } from 'react-use-websocket';
import { APIHost, WebSocketHost } from './../../constants';
import { appInsights } from './../../applicationInsightsService';
import { Icon, Persona, Spinner, SpinnerSize, Stack, makeStyles, mergeStyles } from '@fluentui/react';
import TypingLoader from './TypingLoader';
import { sendRequest } from '../../api';
import DevBotFooter from './DevBotFooter';
import { useId } from '@fluentui/react-hooks';

interface props {
    id: string | undefined,
    token: any,
    userId: any,
    setOnlineState: Function,
    pluginStoreToggle: Function,
    refreshIR: Function,
    setProgramState: Function
    inputText: string
}

export const devBot = (props:props) => {
    const [messages, addMessages] = React.useState<any>([]);
    const [showLoader, setShowLoader] = React.useState<boolean>(false);
    const [disableSend, setDisableSend] = React.useState<boolean>(false);
    const userTypes = ["instruction", "feedback"];
    const chatContainerRef = React.createRef<HTMLDivElement>();
    const [wrapperHeight, setWrapperHeight] = React.useState('300px');

    React.useEffect(() => {
        try {
            if (props.token) {
                sendRequest({
                    url: `${APIHost}/projects/${props.id}/chat`,
                    accessToken: props.token
                })
                .then(response => {
                    addMessages((messages: any) => [...messages, ...response])
                })
            }
        } catch (error) {
            console.log(error);
        }

    }, [props.id, props.token]);

    const {
        getWebSocket,
        readyState,
        sendJsonMessage,
        lastJsonMessage,
    } = useWebSocket(`${WebSocketHost}/projects/${props.id}/chat`, {
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
            if (lastJsonMessage.type === 'output') {
                props.refreshIR();
            }
            if (lastJsonMessage.type === 'dsl_state') {
                let programState;
                try {
                    programState = JSON.parse(lastJsonMessage.message);
                    props.setProgramState(programState);
                } catch (error) {
                    console.log(error);
                }
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

    const getClassNames = (messageType: string) => {
        if (['thought', 'error'].includes(messageType)) {
            return 'no-background'
        }
        if (messageType === 'debug') {
            return 'message debug'
        }
        if (userTypes.includes(messageType)) {
            return 'message user'
        } else {
            return 'message agent'
        }
    }

    const sendMessageToWss = (message: string) => {
        if (message.trim() === "") {
            alert("Please type an instruction")
            return
        }
        let toSendMsg: any = { type: "instruction", message: message }
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

    const chatId = useId('chat')
    const footerId = useId('footer')

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

    const resizedContainerRef = React.useCallback((container: HTMLDivElement) => {
        if (container !== null) {
            resizeObserver.current.observe(container);
        } else {
            if (resizeObserver.current)
                resizeObserver.current.disconnect();
        }
    }, []);

    const onFileChange = async (event: any) => {
        const formData = new FormData();
        const fileNames = []
        for (let i = 0; i < event.target.files.length; i++) {
            fileNames.push(event.target.files[i].name)
            formData.append("files", event.target.files[i]);
        }
        if (props.token) {
            const message = await sendRequest({
                url: `${APIHost}/projects/${props.id}/chat/upload`,
                accessToken: props.token,
                method: "POST",
                body: formData,
            })
            sendRequest({
                url: `${APIHost}/log`,
                accessToken: props.token,
                method: "POST",
                headers: {
                    "Content-Type": 'application/json'
                },
                body: JSON.stringify({
                    name: 'uploadFiles',
                    project_id: props.id,
                    timestamp: new Date().toISOString(),
                    data: { files: fileNames }
                })
            })
            appInsights && appInsights.trackEvent({ name: 'uploadFiles', properties: { projectId: props.id, userId: props.userId, chatType: 'dev', files: fileNames } })
            if (message['error']) {
                console.log('error')
            }
        }
    }

    return (
        <Stack id={chatId} className='devbot'>
            <Stack.Item>
                <div className='chat' style={{ height: wrapperHeight, overflowY: 'auto'}} ref={resizedContainerRef}>
                    {showLoader &&
                        <div className='agent'>
                            <TypingLoader />
                        </div>}
                        {messages ? messages.map((message: any, index: string) => (
                                // <div key={crypto.randomUUID()}>
                                <>
                                    {message.message.trim() !== '' && !['representation_edit', 'files', 'dsl_state'].includes(message.type) &&
                                        <div
                                            key={crypto.randomUUID()}
                                            className={getClassNames(message.type)}
                                        >
                                            <Stack>
                                                <Stack.Item>
                                                    <Stack horizontal={['thought', 'error'].includes(message.type) ? true : false}>
                                                        <Stack.Item>
                                                            {message.type === 'thought' && <Icon iconName="Accept" className='thought-icon' />}
                                                            {message.type === 'error' && <Icon iconName="StatusErrorFull" style={{ color: 'red' }} className='thought-icon' />}
                                                        </Stack.Item>
                                                        <Stack.Item>    
                                                            <div style={{ whiteSpace: 'pre-line', wordBreak: 'break-word', wordWrap:'break-word' }}>
                                                                {message.type === 'output' ? 
                                                                <div dangerouslySetInnerHTML={{ __html: message.message }} />
                                                                : message.message}
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
            <Stack.Item id={footerId} className='footer-stack'>
                <DevBotFooter 
                    inputText={props.inputText}
                    pluginStoreToggle={props.pluginStoreToggle}
                    disableSend={disableSend}
                    sendMessageToWss={sendMessageToWss}
                    onFileChange={onFileChange} 
            />
            </Stack.Item>
        </Stack>
    )

}

export default devBot;