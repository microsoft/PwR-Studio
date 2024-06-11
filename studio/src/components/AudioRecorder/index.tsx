import { useState, useRef } from "react";
import { Stack,IStackStyles, DefaultPalette, IconButton, IIconStyles } from "@fluentui/react";

const mimeType:MediaRecorderOptions = { mimeType: "audio/webm" };

const stackStyles: Partial<IStackStyles> = {
    root: {
        background: DefaultPalette.themeLight,
        color: '#605e5c',
    },
};

const iconStyles: Partial<IIconStyles> = {
    root: {
        fontSize: '30px',
        height: '60px',
        lineHeight: '60px'
    }
}
interface props {
    sendAudioFile: Function
}

const AudioRecorder = (props:props) => {
	const [permission, setPermission] = useState(false);
	const mediaRecorder = useRef<MediaRecorder>();
	const [recordingStatus, setRecordingStatus] = useState("inactive");
	const [stream, setStream] = useState<MediaStream>();
	const [audio, setAudio] = useState<string>();
	const [audioChunks, setAudioChunks] = useState([]);
	const getMicrophonePermission = async () => {
		if ("MediaRecorder" in window) {
			try {
				const mediaStream = await navigator.mediaDevices.getUserMedia({
					audio: true,
					video: false,
				});
				setPermission(true);
				setStream(mediaStream);
			} catch (err:any) {
				alert(err.message);
			}
		} else {
			alert("The MediaRecorder API is not supported in your browser.");
		}
	};

	const startRecording = async () => {
		setRecordingStatus("recording");
        if (stream && mediaRecorder) {
            const media = new MediaRecorder(stream, mimeType);
            mediaRecorder.current = media;
            mediaRecorder.current.start();
            let localAudioChunks:any = [];
            mediaRecorder.current.ondataavailable = (event) => {
                if (typeof event.data === "undefined") return;
                if (event.data.size === 0) return;
                localAudioChunks.push(event.data);
            };
            setAudioChunks(localAudioChunks);
        }		
	};

	const stopRecording = () => {
        if(mediaRecorder.current) {
            setRecordingStatus("inactive");
            mediaRecorder.current.stop();
            mediaRecorder.current.onstop = () => {
                const audioBlob = new Blob(audioChunks, { type: mimeType.mimeType });
                const audioUrl:string = URL.createObjectURL(audioBlob);
                setAudio(audioUrl);
                setAudioChunks([]);
            };
        }
	};

    const getIcon = () => {
        if (permission) {
            return { iconName: recordingStatus === 'inactive' ? "Microphone" : "StopSolid", styles: iconStyles }
        }
        return { iconName: "MicOff", styles: iconStyles }
        
    }

    const sendAudioToServer = async () => {
        if (audio) {
            let blob = await fetch(audio).then(r => r.blob());
            props.sendAudioFile(blob);
        }
    }

	return (
        <Stack horizontal styles={stackStyles}>
            <Stack.Item>
                <IconButton style={{height: '64px' }} iconProps={getIcon()} onClick={() => {
                    if (permission) {
                        if (recordingStatus === 'inactive') {
                            startRecording()
                        } else {
                            stopRecording()
                        }
                    } else {
                        getMicrophonePermission()
                    }
                }}></IconButton>
            </Stack.Item>
            <Stack.Item>
                {audio ? (
                    <Stack horizontal tokens={{childrenGap: 10}}>
                        <Stack.Item>
                            <audio style={{ width: 'calc(100vw - 140px) !important', height: '60px' }} src={audio} controls></audio>
                        </Stack.Item>
                        <Stack.Item>
                            <IconButton style={{ height: '64px', display: 'inline-block'}} iconProps={{iconName: "Send", styles: iconStyles }} onClick={() => sendAudioToServer() }></IconButton>
                        </Stack.Item>
                        <Stack.Item>
                            <IconButton style={{ height: '64px', display: 'inline-block'}} iconProps={{iconName: "Clear", styles: iconStyles }} onClick={() => setAudio('')}></IconButton>
                        </Stack.Item>
                    </Stack>
                ) : null}
            </Stack.Item>
        </Stack>)
};

export default AudioRecorder;