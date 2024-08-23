import { IStackStyles, Stack } from "@fluentui/react";
import { Editor } from "@monaco-editor/react";
import { render } from "@testing-library/react";
import React from "react";
import ReactMarkdown from 'react-markdown';
import gfm from 'remark-gfm';
import MermaidChart from "../Mermaid";
import '../../styles/markdownStyles.css';

interface props {
    representation: any;
    token: string;
}
export const RepView = (props: props) => {
    
    const stackStyle: IStackStyles = {
        root: {
            paddingLeft: '10px',
            height: '100%',
            width: '65vw',
            overflowY: 'scroll',
            selectors: {
                "pre": {
                    whiteSpace: 'pre-wrap',
                    wordBreak: 'break-all',
                    overflowX: 'auto'
                }
            }
        }
    }

    const imageContainerStyle = {
        width: '100%',
        height: '500px',
        overflow: 'auto',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
    };
    
    const renderRepresentation = (representation: any) => {
        if (representation?.name === 'code') {
            return (<Editor options={{ readOnly: true }} defaultValue={representation?.text} height='calc(100vh - 44px)' defaultLanguage="markdown">
            </Editor>)
        }
        if (representation?.name === 'dsl') {
            return (
                <pre>{representation?.text}</pre>
            )
        } else
        

        if (representation?.type === 'md') {
            const processedMarkdown = representation?.text.replace(/"([^"]+)"/g, '<span class="break-word" style="word-break: break-all;">$1</span>');
            return (
                <div className="markdown-body">
                    <ReactMarkdown remarkPlugins={[gfm]}>
                        {processedMarkdown}
                    </ReactMarkdown>
                </div>
            )
        } else if (representation?.type === 'image') {
            if (representation?.text.startsWith('data:image') && representation?.text.includes(';base64,')) {
                return(<div style={imageContainerStyle}>
                    <img src={representation.text} alt="" style={{width: '100%', height: '100%', objectFit: 'contain' }}/>
                </div>)
            } else {
                return(
                    <MermaidChart chart={representation.text} />
                )
            }
        } else if (representation?.type === 'html') {
            return (
                <div dangerouslySetInnerHTML={{__html: representation.text}}></div>
            )
        }
    }
    

    return (
        <Stack styles={stackStyle}>
            <Stack.Item>
                {renderRepresentation(props.representation)}
            </Stack.Item>
        </Stack>
    );
}

export default RepView;