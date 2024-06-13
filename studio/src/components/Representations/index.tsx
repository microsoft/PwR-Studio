import * as React from 'react';
import { useRef, useState, useEffect } from 'react';
import { PrimaryButton, DefaultButton } from '@fluentui/react/lib/Button';
import { Text, ITextStyles, Pivot, PivotItem, FontWeights, DetailsList, Spinner, SelectionMode } from '@fluentui/react';
import { Stack, IStackTokens, IStackItemStyles } from '@fluentui/react/lib/Stack';
import Editor from '@monaco-editor/react';
import { useId } from '@fluentui/react-hooks';
import { APIHost } from '../../constants';
import { sendRequest } from '../../api';
import { appInsights } from './../../applicationInsightsService';

interface props {
    projectId: string | undefined,
    token: any,
    userId: any,
    refreshRepresentation: number
}

const buttonStackTokens: IStackTokens = { childrenGap: 0 };
const buttonStackStyles: IStackItemStyles = { root: { justifyContent: 'space-between' } }
const boldStyle: Partial<ITextStyles> = { root: { fontWeight: FontWeights.semibold } };

export const Representations: React.FunctionComponent<props> = (props: props) => {
    const [wrapperHeight, setWrapperHeight] = useState('100%')
    const editorRef = useRef<any>(null);
    const [editProgress, setEditProgress] = useState<boolean>(false);
    const [tableData, setTableData] = useState<any[]>();
    const [editMode, setEditMode] = useState(false)
    const [currentValue, setCurrentValue] = useState<any>()
    const [selectedRepresentation, selectRepresentation] = useState<any>();
    const [representations, setRepresentation] = useState<any>([])
    const getTabId = (itemKey: string) => {
        return `Representation${itemKey}`;
    };

    const setData = (text: string | undefined) => {
        if (editorRef.current) {
            editorRef.current.setValue(text || "");
            editorRef.current.updateOptions({ wordWrap: "on" })
        }
    }

    const loadTableData = (data: any) => {
        let tables = []
        for (const tableName in data) {
            if (tableName === 'db_name') continue
            let table: any = { columns: [], values: [] }

            if (data.hasOwnProperty(tableName)) {
                for (const columnName in data[tableName]) {
                    if (data[tableName].hasOwnProperty(columnName)) {
                        let maxWidth;
                        if (table.columns.length === 0) {
                            maxWidth = 120
                        }
                        table.columns.push({
                            key: columnName,
                            fieldName: columnName,
                            name: columnName,
                            isResizable: true,
                            isMultiline: true,
                            maxWidth

                        })
                        if (data[tableName][columnName] && data[tableName][columnName]['rows']) {
                            data[tableName][columnName]['rows'].forEach((val: any, index: number) => {
                                if (table.values.length === index) {
                                    table.values.push({
                                        key: index.toString(),
                                        [columnName]: val
                                    })
                                } else {
                                    table.values[index][columnName] = val
                                }
                            })
                        }
                    }
                }
                tables.push({
                    name: tableName,
                    table
                })
            }
        }
        setTableData(tables)
    }

    useEffect(() => {
        if (selectedRepresentation) {
            if (selectedRepresentation?.type === 'json') {
                loadTableData(JSON.parse(selectedRepresentation.text || '{}'))
            } else {
                setData(selectedRepresentation.text);
            }
        }
    }, [selectedRepresentation, selectedRepresentation?.text])


    useEffect(() => {
        if (props.token) {
            sendRequest({
                url: `${APIHost}/projects/${props.projectId}/representations`,
                accessToken: props.token
            })
                .then(response => {
                    if (response.length) {
                        setRepresentation(response)
                        if (response.length) {
                            setTimeout(() => {
                                const viewRepr = response.filter((r: any) => r.is_pbyc_viewable)
                                if (viewRepr) {
                                    selectRepresentation(viewRepr[0])
                                    setData(viewRepr[0].text)
                                }
                            }, 0)
                        }
                    }
                })
        }

    }, [props.projectId, props.token, props.refreshRepresentation])

    const editIteration = () => {
        if (editProgress) return;
        setEditProgress(true)

        const credentials = JSON.parse(localStorage.getItem(`project-${props.projectId}-credentials`) || '{}')
        const engine_url = localStorage.getItem(`project-${props.projectId}-function-url`)
        sendRequest({
            url: `${APIHost}/projects/${props.projectId}/take_edit`,
            accessToken: props.token,
            method: "POST",
            headers: {
                "Content-Type": 'application/json'
            },
            body: JSON.stringify({
                engine_url,
                credentials,
                changed_representation: {
                    name: selectedRepresentation.name,
                    text: currentValue || selectedRepresentation?.text
                }
            })
        })
            .then(response => {

                sendRequest({
                    url: `${APIHost}/log`,
                    accessToken: props.token,
                    method: "POST",
                    headers: {
                        "Content-Type": 'application/json'
                    },
                    body: JSON.stringify({
                        name: 'representationEditSubmit',
                        project_id: props.projectId,
                        user_id: props.userId,
                        timestamp: new Date().toISOString(),
                        representation_name: selectedRepresentation.name
                    })
                })
                appInsights && appInsights.trackEvent({ name: 'representationEditSubmit', properties: { projectId: props.projectId, userId: props.userId } })

                setEditProgress(false)
                setEditMode(false);
            })
    }

    const getButtons = (r: any, eMode: boolean) => {
        if (r && r.type !== 'json') {
            if (eMode) {
                editorRef?.current?.updateOptions({ readOnly: !!!eMode })
                return (
                    <div>
                        <PrimaryButton onClick={editIteration}>Submit {editProgress ? <Spinner /> : ""}</PrimaryButton>&nbsp;
                        <DefaultButton onClick={() => {
                            sendRequest({
                                url: `${APIHost}/log`,
                                accessToken: props.token,
                                method: "POST",
                                headers: {
                                    "Content-Type": 'application/json'
                                },
                                body: JSON.stringify({
                                    name: 'representationEditDiscard',
                                    project_id: props.projectId,
                                    user_id: props.userId,
                                    timestamp: new Date().toISOString(),
                                    representation_name: selectedRepresentation.name
                                })
                            })
                            appInsights && appInsights.trackEvent({ name: 'representationEditDiscard', properties: { projectId: props.projectId, userId: props.userId } });
                            const value = selectedRepresentation?.text;
                            editorRef?.current?.setValue(value); setEditMode(false);
                        }
                        }>Discard</DefaultButton>
                    </div>)
            } else {
                editorRef?.current?.updateOptions({ readOnly: !!!eMode })
                return <PrimaryButton disabled={selectedRepresentation?.is_editable === false ? true : false} onClick={() => {
                    sendRequest({
                        url: `${APIHost}/log`,
                        accessToken: props.token,
                        method: "POST",
                        headers: {
                            "Content-Type": 'application/json'
                        },
                        body: JSON.stringify({
                            name: 'representationEditClick',
                            project_id: props.projectId,
                            user_id: props.userId,
                            timestamp: new Date().toISOString(),
                            representation_name: selectedRepresentation.name
                        })
                    })
                    appInsights && appInsights.trackEvent({ name: 'representationEditClick', properties: { projectId: props.projectId, userId: props.userId } });
                    setEditMode(true)
                }}>Edit</PrimaryButton>
            }
        }
    }

    const _getKey = (item: any, index?: number): string => {
        return item.key;
    }
    const representationId = useId('representationWrapper')
    const resizeObserver = React.useRef<ResizeObserver>(new ResizeObserver((entries: ResizeObserverEntry[]) => {
        window.requestAnimationFrame(() => {
            const container = document.getElementById(representationId);
            if (container) {
                setWrapperHeight(window.innerHeight - container.getBoundingClientRect().top + 'px')
            }
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
    const imageContainerStyle = {
        width: '100%', // Set container width
        height: '500px', // Set a fixed height or use '100%'
        overflow: 'auto', // Allow scrolling
        display: 'flex', // Use flexbox for centering
        alignItems: 'center', // Center vertically
        justifyContent: 'center', // Center horizontally
    };

    const renderRepresentation = () => {
        if (selectedRepresentation?.type === 'json') {
                return (<div style={{ display: 'inherit', width: '50vw', height: '100%', flexDirection: 'column', flex: 1, overflow: 'auto', wordBreak: 'break-word' }}>
                    {tableData?.map((t: any, index: number) => {
                        return (
                            <>
                                <Text block variant="medium" style={{ padding: 10 }} styles={boldStyle}>{t.name}</Text>
                                <DetailsList
                                    key={"t-" + index}
                                    selectionMode={SelectionMode.none}
                                    compact
                                    getKey={_getKey}
                                    columns={t.table.columns}
                                    items={t.table.values}
                                />
                            </>
                        );
                    })}
                </div>
                )
        } else if (selectedRepresentation?.type === 'image'){
            return (
                <div style={imageContainerStyle}>
                    <img src={selectedRepresentation.text} alt="" style={{width: '100%', height: '100%', objectFit: 'contain' }}/>
                </div>
            )
        } else {
            return (<Editor options={{ readOnly: !!!editMode }} defaultValue={selectedRepresentation?.text} onChange={(value, ev) => { setCurrentValue(value); }} onMount={(editor) => { editorRef.current = editor; }} height="calc(100% - 25px)" defaultLanguage="markdown">
            </Editor>)
        }
                
    }

    return (
        <div id={representationId} ref={resizedContainerRef} style={{ height: wrapperHeight }}>
            <Text block variant="medium" styles={boldStyle}>Representations</Text>
            <Stack horizontal styles={buttonStackStyles} tokens={buttonStackTokens}>
                <Stack.Item>
                    {representations ?
                        <Pivot
                            aria-label="Separately Rendered Content Pivot Example"
                            selectedKey={selectedRepresentation}
                            // eslint-disable-next-line react/jsx-no-bind
                            onLinkClick={(item?: PivotItem, ev?: any) => {
                                if (editMode) {
                                    alert('Please submit or discard your changes before switching representations.');
                                    return false;
                                }
                                if (item && !editMode) {
                                    sendRequest({
                                        url: `${APIHost}/log`,
                                        accessToken: props.token,
                                        method: "POST",
                                        headers: {
                                            "Content-Type": 'application/json'
                                        },
                                        body: JSON.stringify({
                                            name: 'representationClick',
                                            project_id: props.projectId,
                                            user_id: props.userId,
                                            timestamp: new Date().toISOString(),
                                            representation_name: item.props.itemKey
                                        })
                                    })
                                    appInsights && appInsights.trackEvent({ name: 'representationClick', properties: { representationName: item.props.itemKey, projectId: props.projectId, userId: props.userId } })
                                    selectRepresentation(representations.find((r: any) => r.name === item.props.itemKey));
                                }
                            }}
                            headersOnly={true}
                            getTabId={getTabId}
                        >
                            {representations && representations.filter((r: any) => r.is_pbyc_viewable).map((representation: any) => {
                                return (representation.is_pbyc_viewable) ? <PivotItem headerButtonProps={{
                                    'disabled': editMode
                                }} key={'tab-' + representation.name} headerText={representation.name} itemKey={representation.name} /> : ""
                            })}
                        </Pivot>

                        : ""}
                </Stack.Item>
                <Stack.Item>
                    {getButtons(selectedRepresentation, editMode)}
                </Stack.Item>
            </Stack>
            {renderRepresentation()}
        </div>
    )
}

export default Representations;
