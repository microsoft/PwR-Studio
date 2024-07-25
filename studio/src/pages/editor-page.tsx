import { DefaultButton, DefaultPalette, FontIcon, FontSizes, FontWeights, IButtonStyles, IStackItemStyles, ITextStyles, Icon, IconButton, Modal, OverflowSet, Stack, makeStyles, mergeStyles } from '@fluentui/react';
import '@/styles/pages/editor.scss';
import { DevBot, PluginList } from '../components';
import { useId, useBoolean } from '@fluentui/react-hooks';
import { Pivot, PivotItem, IPivotStyles, Text } from '@fluentui/react';
import React from 'react';
import { useState } from 'react';
import { APIHost } from '../constants';
import { useParams } from 'react-router-dom';
import { sendRequest } from '../api';
import { useAccount, useMsal } from '@azure/msal-react';
import { InteractionRequiredAuthError } from "@azure/msal-browser";
import RepView from '../components/Representations/RepView';
import TestBot from '../components/Chat/TestBot';
import { useTranslation } from 'react-i18next';
import PublishModal from '../components/PublishModal';

const boldHeaderStyle: Partial<ITextStyles> = { root: { fontWeight: FontWeights.semibold, color: '#696969' } };

const logoutButtonStackItem: IStackItemStyles = {
  root: {
    marginTop: 'auto',
  },
};

const chatModePivotStyle: Partial<IPivotStyles> = {
    link: {
        color: '#5694FF',
        padding: 10,
        margin: 0,
        width: '120px',
        ":hover": {
            background: '#5694FF',
            color: '#FFF'
        }
    },
    linkIsSelected: {
        background: '#5694FF',
        color: '#FFF',
        "not(:last-child)": {
            borderTopRightRadius: '12px',
            borderBottomRightRadius: '12px',
        },
        "not(:first-child)": {
            borderTopLeftRadius: '12px',
            borderBottomLeftRadius: '12px',
        },
        ":before": {
            height: '0px !important'
        },
        ":hover": {
            background: '#5694FF',
            color: '#FFF'
        }
    }
}


export const EditorPage: React.FunctionComponent = () => {
    const { t, i18n} = useTranslation();
    const [projectDetails, setProjectDetails] = React.useState<any>();
    const params = useParams();
    const [userId, setUserId] = React.useState<string | undefined>(undefined);
    const [devChatOnline, setDevChatStatus] = React.useState<boolean>(false);
    const [sandboxChatOnline, setSandboxChatStatus] = React.useState<boolean>(false);
    const [token, setToken] = React.useState<any>(null);
    const [isPublishModalOpen, { setTrue: showPublishModal, setFalse: hidePublishModal }] = useBoolean(false);
    const [isPluginStoreOpen, { setTrue: showPluginStore, setFalse: hidePluginStore }] = useBoolean(false);
    const [plugins, setPlugins] = React.useState<any>();
    const [userName, setName] = React.useState<string>('')
    const [programState, setProgramState] = useState<any>(null)
    const [representations, setRepresentation] = useState<any>([]);
    const [selectedRepresentation, selectRepresentation] = useState<any>();
    const { instance, accounts, inProgress } = useMsal();
    const account = useAccount(accounts[0] || {});
    const [chatMode, setChatMode] = React.useState<string>('DevMode');
    const [refreshIR, setRefreshIR] = React.useState<number>(0);
    const [inputText, setInputText] = React.useState<string>('');
    const fileInput = React.createRef<HTMLInputElement>();
    const [dslImportLoader, setDslImportLoader] = React.useState<boolean>(false);
    const [resetTestChat, setResetTestChat] = React.useState<boolean>(false);

    React.useEffect(() => {
        if (token && params.id) {
            sendRequest({
                url: `${APIHost}/projects/${params.id}`,
                accessToken: token
            })
                .then(response => {
                    setProjectDetails(response)
                }).catch((error) => {
                    console.log(error)
                    if (error?.status === 403) {
                        alert(t('unauthorizedAccess'));
                        window.location.href = `#/home`;
                    }   
                })
        }
    }, [params.id, token, userId])

    React.useEffect(() => {
    if (account && inProgress === "none") {
            instance.acquireTokenSilent({
                scopes: [import.meta.env.VITE_REACT_APP_ADD_APP_SCOPE_URI || ''],
                account: account
            }).then((response) => {
                setToken(response.idToken)
                setName(response?.account?.idTokenClaims?.name || 'User')
                setUserId(response?.account?.idTokenClaims?.oid)
            }).catch((error) => {
                console.log(error)
                // in case if silent token acquisition fails, fallback to an interactive method
                if (error instanceof InteractionRequiredAuthError) {
                    if (account && inProgress === "none") {
                        instance.acquireTokenPopup({
                            scopes: [import.meta.env.VITE_REACT_APP_ADD_APP_SCOPE_URI || ''],
                        }).then((response) => {
                            setToken(response.idToken)
                            setUserId(response?.account?.idTokenClaims?.oid)
                        }).catch(error => console.log(error));
                    }
                }
            });
        }
    }, [account, inProgress, instance]);

    React.useEffect(() => {
        if (token) {
            sendRequest({
                url: `${APIHost}/projects/${params.id}/representations`,
                accessToken: token
            })
                .then(response => {
                    if (response.length) {
                        // sort response array by sort_order in increasing number
                        response = response.sort((a: any, b: any) => b.sort_order - a.sort_order)
                        setRepresentation(response)
                        if (response.length) {
                            setTimeout(() => {
                                const viewRepr = response.filter((r: any) => r.is_pwr_viewable)
                                if (viewRepr) {
                                    selectRepresentation(viewRepr[0])
                                }
                            }, 0)
                        }
                    }
                })
            sendRequest({
                url: `${APIHost}/error_states/${params.id}`,
                accessToken: token
            }).then(response => {
                    if (response && response.length) {
                        try {
                            response = JSON.parse(response[0].message)
                            setProgramState(response)
                        } catch (error) {
                            console.log(error)
                        }
                        
                    }
            })
        }

    }, [params.id, token, refreshIR])

    const chatModes = [{
        itemKey: 'DevMode',
        headerText: t('editorPage.devModeHeader')
    }, {
        itemKey: 'TestMode',
        headerText: t('editorPage.testModeHeader')
    }]

    const onRenderOverflowButton = (overflowItems: any[] | undefined): JSX.Element => {
        const buttonStyles: Partial<IButtonStyles> = {
          root: {
            fontSize: FontSizes.size24,
            minWidth: 0,
            padding: '0 4px',
            alignSelf: 'stretch',
            height: '24px',
          },
          menuIcon: {
            fontSize: FontSizes.size16,
            fontWeight: 'bolder'
          }
        };
        return (
          <IconButton
            title={t('moreOptions')}
            styles={buttonStyles}
            menuIconProps={{ iconName: 'MoreVertical' }}
            menuProps={{ items: overflowItems! }}
          />
        );
      };
    // hardcoded icons for now, later use it from db
    const hardcodedIcons:any = {
        'code': 'CodeEdit',
        'description': 'AlignLeft',
        'dsl': 'GridViewMedium',
        'diagram': 'VisioDiagram'
    }

    const pluginCallback = (text:string) => {
        hidePluginStore();
        setInputText(text);
        setTimeout(() => {
            setInputText('');
        }, 500)
        navigator.clipboard.writeText(text);
    }

    React.useEffect(() => {
        if (isPluginStoreOpen) {
            sendRequest({
                url: `${APIHost}/templates/${projectDetails?.project_class}/plugins`,
                accessToken: token
            }).then(response => {
                setPlugins(response)
                console.log(response)
            }).catch((error) => {
                console.log(error)
            })
        }
    }, [isPluginStoreOpen]);
    const iconClass = mergeStyles({
        fontSize: 25,
        height: 25,
        width: 25
    });

    const chatModeClass = () => {
        let className = 'chat-button';
        className += devChatOnline ? ' dev-online' : ''
        className += sandboxChatOnline ? ' sandbox-online' : ''
        return className;
    }

    const onFileChange = async (event:any) => {
        if (event.target.files.length > 0) {
            const formData = new FormData();
            formData.append('dsl', event.target.files[0]);
            if (token) {
                setDslImportLoader(true);
                sendRequest({
                    url: `${APIHost}/import_dsl/${params.id}`,
                    method: 'POST',
                    accessToken: token,
                    body: formData
                }).then(response => {
                    alert(t('dslImportSuccess'));
                    setDslImportLoader(false);
                    event.target.value = null;
                }).catch((error) => {
                    alert(t('dslImportError'));
                    setDslImportLoader(false);
                    event.target.value = null;
                })
            }
        }
    }

    const renderRep = (item: any, index: number) => {
        if (item.name !== 'fsm_state') {
            return (<Stack.Item 
                className={item.name === selectedRepresentation?.name ? 'rep-icon selected' : 'rep-icon'}
                key={index}>
                <IconButton 
                    iconProps={{ iconName: hardcodedIcons[item.name] || '' }}
                    onClick={() => selectRepresentation(item)}
                >
                        {item.name}
                </IconButton>
            </Stack.Item>)
        }
    }

    return (
        <Stack className='editor-page'>
            <Stack.Item>
                <PublishModal isOpen={isPublishModalOpen} hideModal={hidePublishModal} representations={representations} dslName={projectDetails?.name}/>
                <Modal
                    titleAriaId={useId('pluginStore')}
                    isBlocking={true}
                    isOpen={isPluginStoreOpen}
                    scrollableContentClassName=''
                    containerClassName={'modal-container'}
                >
                    <Stack>
                        <Stack.Item>
                            <Stack className={'modal-header'} horizontal style={{ 'width': '100%', justifyContent: 'space-between' }}>
                                <Stack.Item >
                                    <Text variant="xxLarge" styles={boldHeaderStyle}> Features</Text>
                                </Stack.Item>
                                <Stack.Item>
                                    <FontIcon 
                                        aria-label="Close"
                                        iconName="ChromeClose"
                                        className={iconClass} 
                                        onClick={() => hidePluginStore()}
                                        />
                                </Stack.Item>
                            </Stack>    
                        </Stack.Item>
                        <Stack.Item>
                            <PluginList plugins={plugins} pluginCallback={pluginCallback} />
                        </Stack.Item>
                    </Stack>

                </Modal>
                <Stack horizontal className={'header'}>
                    <Stack.Item className={'heading'} onClick={() => window.location.href = '/#/home' }>
                        PwR Studio
                    </Stack.Item>
                    <Stack.Item className={'project-name'}>
                        {projectDetails?.name}
                    </Stack.Item>
                    <Stack.Item>
                        <Stack horizontal tokens={{ childrenGap: 10 }}>
                            <Stack.Item>
                                <DefaultButton disabled={dslImportLoader} className='' onClick={() => { window.event?.stopImmediatePropagation(); fileInput?.current?.click(); }}>{t("dslFileupload")} &nbsp;{dslImportLoader && <Icon iconName="Sync" className="loader" />}</DefaultButton>
                                <input id="dslInput" ref={fileInput} accept=".dsl, .txt" onChange={onFileChange} type='file' hidden />
                            </Stack.Item>
                            <Stack.Item>
                                <DefaultButton onClick={showPublishModal} className={'secondary-button'}>Publish</DefaultButton>
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                </Stack>
            </Stack.Item>
            <Stack.Item>
                <Stack horizontal className={'content-row'}>
                    <Stack.Item className={'sidebar'}>
                        <Stack verticalAlign='start' style={{ height: '100%' }}>
                            {representations && representations.map((item: any, index: number) => {
                                return renderRep(item, index)
                                    
                                })
                            }
                            <Stack.Item align="end" styles={logoutButtonStackItem} className={'logout'}>
                                <IconButton onClick={() => { instance.logoutPopup(); window.location.href = `#/` } } iconProps={{ iconName: 'PowerButton' }} title={t('logout')} ariaLabel={t('logout')} />
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                    <Stack.Item className={'ir'}>
                        <Stack className={'container'}>
                            <Stack.Item className={'content'}>
                                <RepView representation={selectedRepresentation} token={token} />
                            </Stack.Item>
                            <Stack.Item>
                                <Stack horizontal className={'errors'}>
                                    <Stack.Item className={'error'}>
                                        <Stack horizontal className={'content'}>
                                            <Stack.Item>
                                                <Icon iconName="StatusErrorFull" /> Errors
                                            </Stack.Item>
                                            <Stack.Item>
                                                {programState?.errors || 0}
                                            </Stack.Item>
                                        </Stack>
                                    </Stack.Item>
                                    <Stack.Item className={'warnings'}>
                                    <Stack horizontal className={'content'}>
                                            <Stack.Item>
                                                <Icon iconName="WarningSolid" /> Warnings
                                            </Stack.Item>
                                            <Stack.Item>
                                                {programState?.warnings || 0}
                                            </Stack.Item>
                                        </Stack>
                                    </Stack.Item>
                                    <Stack.Item className={'optimize'}>
                                        <Stack horizontal className={'content'}>
                                            <Stack.Item>
                                                <Icon iconName="Chart" /> Optimize
                                            </Stack.Item>
                                            <Stack.Item>
                                                {programState?.optimizations || 0}
                                            </Stack.Item>
                                        </Stack>
                                    </Stack.Item>
                                    <Stack.Item className={'bot-experience'}>
                                        <Stack horizontal className={'content'}>
                                            <Stack.Item>
                                                <Icon iconName="FavoriteStarFill" /> Bot Experience
                                            </Stack.Item>
                                            <Stack.Item>
                                                {programState?.botExperience || 0}
                                            </Stack.Item>
                                        </Stack>
                                    </Stack.Item>
                                </Stack>
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                    <Stack.Item className={'chat-wrapper'}>
                        <Stack>
                            <Stack.Item>
                                <Stack horizontal className={'chat-header'}>
                                    <Stack.Item>
                                        <Pivot 
                                            onLinkClick={(item?: PivotItem, ev?: any) => {
                                                setChatMode(item?.props.itemKey || 'DevMode')
                                            }}
                                            className={chatModeClass()} styles={chatModePivotStyle}>
                                            {chatModes.map((item, index) => {
                                                return (
                                                    <PivotItem 
                                                        headerText={item.headerText} itemKey={item.itemKey} key={index} 
                                                    />
                                                )
                                            })}
                                        </Pivot>
                                    </Stack.Item>
                                    <Stack.Item>
                                        <OverflowSet
                                                aria-label="Actions"
                                                style={{ display: chatMode === 'TestMode' ? 'block': 'none' }}
                                                overflowItems={[
                                                {
                                                    key: 'download',
                                                    name: t('downloadTranscript'),
                                                    iconProps: { iconName: 'Download' },
                                                    onClick: () => {},
                                                },
                                                {
                                                    key: 'callbackFrom',
                                                    name: t('callbackFrom'),
                                                    iconProps: { iconName: 'FormLibrary' },
                                                    onclick: () => {}
                                                },
                                                {
                                                    key: 'clearData',
                                                    name: t('resetChat'),
                                                    iconProps: { iconName: 'Rerun' },
                                                    onClick: () => {
                                                        setResetTestChat(true);
                                                    },
                                                }
                                                ]}
                                                onRenderOverflowButton={onRenderOverflowButton}
                                                onRenderItem={() => {}}
                                            />
                                    </Stack.Item>
                                </Stack>
                            </Stack.Item>
                            <Stack.Item>
                                <div style={{ display: chatMode === 'DevMode' ? 'block': 'none' }}>
                                    <DevBot inputText={inputText} setProgramState={setProgramState} refreshIR={() => setRefreshIR(refreshIR + 1) } pluginStoreToggle={showPluginStore} userId={userId} setOnlineState={setDevChatStatus} id={params.id} token={token} />
                                </div>
                                <div style={{ display: chatMode === 'TestMode' ? 'block': 'none' }}>
                                    <TestBot userId={userId} setOnlineState={setSandboxChatStatus} id={params.id} token={token} resetChat={resetTestChat} resetChatToggle={setResetTestChat}/>
                                </div>
                            </Stack.Item> 
                        </Stack>
                    </Stack.Item>
                </Stack>
            </Stack.Item>
        </Stack>
    )

}

export default EditorPage;