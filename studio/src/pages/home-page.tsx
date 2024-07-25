import * as React from 'react';
import '@/styles/pages/home.scss';
import { DefaultButton, Icon, IconButton, MessageBar, MessageBarType, Modal, PrimaryButton, Stack, TextField } from "@fluentui/react";
import { SearchBox } from '@fluentui/react/lib/SearchBox';
import { useTranslation } from "react-i18next";
import { useId } from '@fluentui/react-hooks';
import { useAccount, useMsal } from '@azure/msal-react';
import { InteractionRequiredAuthError } from '@azure/msal-browser';
import { sendRequest } from '../api';
import { APIHost } from '../constants';
import moment from 'moment';
import { appInsights } from '../applicationInsightsService';
import logo from './images/logo.png';


export const HomePage: React.FunctionComponent = () => {
    const { t } = useTranslation();
    const [disabled, setDisabled] = React.useState(false);
    const [copyTemplateValues, setTemplateValues] = React.useState({
        name: '',
        description: '',
        id: '',
        project_class: '',
        dsl: {
            name: '',
            file: null
        }
    });
    const { instance, accounts, inProgress } = useMsal();
    const account = useAccount(accounts[0] || {});
    const [filteredProjects, setFilteredProjects] = React.useState([]);
    const [modalToggle, toggleModal] = React.useState<string | null>(null);
    const [email, setEmail] = React.useState('');
    const [searchQuery, setQuery] = React.useState('');
    const [serverMessage, setServerMessage] = React.useState({ message: '', type: '' });
    const [projects, setProjects] = React.useState<any>([])
    const [userId, setUserId] = React.useState<string | undefined>(undefined)
    const [token, setToken] = React.useState<any>(null);
    const [shareProjectId, setProjectId] = React.useState<string>('');
    const fileInput = React.createRef<HTMLInputElement>();

    const onSearch = (query:string) => {
        const filtered = projects.filter((item:any) =>
          item.name.toLowerCase().includes(query.toLowerCase()) || item.description.toLowerCase().includes(query.toLowerCase())
        );
        setQuery(query);
        setFilteredProjects(filtered);
    };    

    React.useEffect(() => {
        if (account && inProgress === "none") {
            instance.acquireTokenSilent({
                scopes: [import.meta.env.VITE_REACT_APP_ADD_APP_SCOPE_URI || ''],
                account: account
            }).then((response) => {
                console.log(response)
                setToken(response.idToken)
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

    const clickAction = (project: any) => {
        sendRequest({
            url: `${APIHost}/log`,
            accessToken: token,
            method: "POST",
            headers: {
                "Content-Type": 'application/json'
            },
            body: JSON.stringify({ name: 'openProject', user_id: userId, project_id: project.id, timestamp: new Date().toISOString() })
        })
        appInsights && appInsights.trackEvent({ name: 'openProject', properties: { projectId: project.id, userId: userId } })
        window.location.href = `#/editor/${project.id}`
    }

    React.useEffect(() => {
        try {
            if (token) {
                sendRequest({
                    url: `${APIHost}/projects`,
                    accessToken: token
                })
                    .then(response => {
                        setFilteredProjects(response);
                        setProjects(response);

                    })
            }
        } catch (error) {

        }
    }, [token, userId]);


    const openShareProject = (action: any, ev: React.MouseEvent<HTMLButtonElement>): void => {
        ev.stopPropagation();
        ev.preventDefault();
        toggleModal('shareProject');
        setProjectId(action.id);
    }
    const shareProject = () => {
        if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(email)) {
            setServerMessage({ message: 'Please enter a valid email address', type: 'error' })
            return;
        }

        if (token) {
            if (disabled) return
            setDisabled(true)
            sendRequest({
                url: `${APIHost}/projects/${shareProjectId}/share`,
                accessToken: token,
                method: "POST",
                headers: {
                    "Content-Type": 'application/json'
                },
                body: JSON.stringify({
                    email
                })
            })
                .then(response => {
                    setServerMessage(response?.message)
                    setDisabled(false)
                    if (response) {
                        setTimeout(() => {
                            setServerMessage({ message: '', type: '' });
                            toggleModal(null);
                        }, 5000)
                        sendRequest({
                            url: `${APIHost}/log`,
                            accessToken: token,
                            method: "POST",
                            headers: {
                                "Content-Type": 'application/json'
                            },
                            body: JSON.stringify({
                                name: 'shareProject',
                                user_id: userId,
                                project_id: shareProjectId,
                                timestamp: new Date().toISOString(),
                                data: { email: email }
                            })
                        }).then(res => {
                            appInsights && appInsights.trackEvent({ name: 'shareProject', properties: { templateId: copyTemplateValues.id, userId: userId, data: copyTemplateValues } })
                        })
                    }
                }).catch(error => {
                    setDisabled(false)
                    setServerMessage({
                        message: error?.message,
                        type: 'error'
                    })
                    console.log(error)
                })
        }
    }

    React.useEffect(() => {
        if (token) {
            sendRequest({
                url: `${APIHost}/templates`,
                accessToken: token
            }).then(response => {  
                const jbTemplate = response.find((res:any) => res.project_class === 'jb_app')
                setTemplateValues({
                    name: '',
                    description: '',
                    id: jbTemplate.id,
                    project_class: jbTemplate.project_class,
                    dsl: {
                        name: copyTemplateValues.dsl.name,
                        file: copyTemplateValues.dsl.file
                    }
                })
            })
        }
    }, [token])

    const onActionClick = (action: any): void => {
        console.log(`You clicked the ${action} action`);
        console.log(action);
        setTemplateValues({
            name: action.name,
            description: action.description,
            id: copyTemplateValues.id,
            project_class: copyTemplateValues.project_class,
            dsl: {
                name: copyTemplateValues.dsl.name,
                file: copyTemplateValues.dsl.file
            }
        })
        toggleModal('copyTemplate');
        setDisabled(false);
    };

    const copyTemplate = (copyTemplateValues: any) => {
        try {
            if (token) {
                if (copyTemplateValues.name.trim() === '') {
                    alert(t('homePage.nameRequiredAlert'));
                    return;
                }
                if (disabled) return
                setDisabled(true)
                const formData = new FormData();
                if (copyTemplateValues.dsl.file) {
                    formData.append('dsl', copyTemplateValues.dsl.file);
                }
                formData.append('name', copyTemplateValues.name);
                formData.append('description', copyTemplateValues.description);
                formData.append('project_class', copyTemplateValues.project_class);
                sendRequest({
                    url: `${APIHost}/projects?template_id=${copyTemplateValues.id}`,
                    accessToken: token,
                    method: "POST",
                    body: formData
                })
                    .then(response => {
                        const projectId = response?.id
                        setDisabled(false)
                        if (response) {
                            sendRequest({
                                url: `${APIHost}/log`,
                                accessToken: token,
                                method: "POST",
                                headers: {
                                    "Content-Type": 'application/json'
                                },
                                body: JSON.stringify({
                                    name: 'templateCopy',
                                    user_id: userId,
                                    project_id: projectId,
                                    timestamp: new Date().toISOString(),
                                    data: { template_id: copyTemplateValues.id }
                                })
                            }).then(res => {
                                appInsights && appInsights.trackEvent({ name: 'templateCopy', properties: { templateId: copyTemplateValues.id, userId: userId, data: copyTemplateValues } })
                                window.location.href = `#/editor/${projectId}`;
                            })
                        }
                    })

            }
        } catch (error) {
            setDisabled(false)
            appInsights && appInsights.trackException({ error: new Error(`Error in duplicating template - ${copyTemplateValues.id} for user - ${userId}`), severityLevel: SeverityLevel.Error });
            console.log(error)
        }
    }

    const deleteProject = (action: any, ev: React.MouseEvent<HTMLButtonElement>): void => {
        ev.stopPropagation();
        ev.preventDefault();
        if (window.confirm(`Are you sure want to delete the project(${action.name})?`)) {
            sendRequest({
                url: `${APIHost}/projects/${action.id}`,
                method: "DELETE",
                accessToken: token
            })
                .then(response => {
                    //Fetch projects again
                    sendRequest({
                        url: `${APIHost}/projects`,
                        accessToken: token
                    }).then(response => {
                            setProjects(response);
                            onSearch(searchQuery);
                        })
                }).catch(error => {
                    alert(t('homePage.deleteProjectError'));
                })
        }
    };

    const onFileChange = async (event:any) => {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            copyTemplateValues.dsl.file = file;
            copyTemplateValues.dsl.name = file.name;
        }
    }

    return (
        <Stack className="home-page">
            <Modal
                titleAriaId={useId('copyTemplate')}
                isOpen={modalToggle === 'copyTemplate'}
                onDismiss={() => { toggleModal(null) }}
                isBlocking={false}
                containerClassName={'modal-container'}
            >
                <div className={'modal-header'}>
                    <div className={'modal-heading'}>
                        {t('createNewProject')}
                    </div>
                    <IconButton
                        className={'modal-close'}
                        iconProps={{ iconName: 'Cancel' }}
                        ariaLabel="Close popup modal"
                        onClick={() => { toggleModal(null) }}
                    />
                </div>
                <div className={'modal-body'}>
                    {serverMessage.message &&
                        <MessageBar
                            messageBarType={serverMessage.type === 'success' ? MessageBarType.success : MessageBarType.error}
                            onDismiss={() => { setServerMessage({ message: '', type: '' }) }}
                            isMultiline={false}
                            dismissButtonAriaLabel="Close"
                        >
                            {serverMessage.message}
                        </MessageBar>
                    }
                    <TextField label="Name" onChange={(e, value) => { copyTemplateValues.name = value || '' }} defaultValue={copyTemplateValues.name} />
                    <TextField label="Description" onChange={(e, value) => { copyTemplateValues.description = value || '' }} defaultValue={copyTemplateValues.description} multiline resizable={false} />
                                       
                    <div style={{height:'10px'}}>&nbsp;</div>
                    <MessageBar>
                       {t('homePage.dslFileUploadMessage')}
                    </MessageBar>
                    <input id="dslInput" ref={fileInput} accept=".dsl, .txt" onChange={onFileChange} type='file' hidden />
                    <label htmlFor="dslInput">
                        <Stack horizontal style={{ marginTop: '10px' }}>
                            <Stack.Item>
                                <DefaultButton className='small' onClick={() => { window.event?.stopImmediatePropagation(); fileInput?.current?.click(); }}>{t("dslFileUpload")}</DefaultButton>
                            </Stack.Item>
                            <Stack.Item>
                                {copyTemplateValues.dsl.name && <span style={{ lineHeight: '30px', paddingLeft: '10px' }}>Selected file: {copyTemplateValues.dsl.name}</span>}
                            </Stack.Item>
                        </Stack>    
                    </label>
                </div>
                <div className={'modal-footer'}>
                    <DefaultButton className='secondary-button' disabled={disabled} onClick={() => copyTemplate(copyTemplateValues)}>
                        Create
                    </DefaultButton>
                    <DefaultButton text={t("cancel")} onClick={() => { toggleModal(null) }} />
                </div>

            </Modal>
            <Modal
                titleAriaId={useId('shareProject')}
                isOpen={modalToggle === 'shareProject'}
                onDismiss={() => { toggleModal(null) }}
                isBlocking={false}
                containerClassName="modal-container"
            >
                <div className={'modal-header'}>
                    <div className={'modal-heading'}>
                        {t('shareProject')}
                    </div>
                    <IconButton
                        className={'modal-close'}
                        iconProps={{ iconName: 'Cancel' }}
                        ariaLabel="Close popup modal"
                        onClick={() => { toggleModal(null) }}
                    />
                </div>
                <div className={'modal-body'}>
                    {serverMessage.message &&
                        <MessageBar
                            messageBarType={serverMessage.type === 'success' ? MessageBarType.success : MessageBarType.error}
                            onDismiss={() => { setServerMessage({ message: '', type: '' }) }}
                            isMultiline={false}
                            dismissButtonAriaLabel="Close"
                        >
                            {serverMessage.message}
                        </MessageBar>
                    }
                    <TextField label="Email" onChange={(e, value) => { setEmail(value || '') }} />
                </div>
                <div className={'modal-footer'}>
                    <DefaultButton className='secondary-button' disabled={disabled} onClick={() => shareProject()}>
                        Share Project
                    </DefaultButton>
                    <DefaultButton text={t('cancel')} onClick={() => { toggleModal(null) }} />
                </div>
            </Modal>
            <Stack.Item>
                <Stack horizontal className="header">
                    <Stack.Item className={'heading'}>
                        PwR Studio
                    </Stack.Item>
                </Stack>
            </Stack.Item>
            <Stack.Item>
                <Stack horizontal className={'content-row'}>
                    <Stack.Item className={'sidebar'}>
                        <Stack verticalAlign='end' style={{ height: '100%' }}>
                            <Stack.Item align='center' className={'logout'}>
                                <IconButton onClick={() => { instance.logoutPopup(); window.location.href = `#/` } } iconProps={{ iconName: 'SignOut' }} title={t('logout')} ariaLabel={t('logout')} />
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                    <Stack.Item className={'content'}>
                        <Stack className={'content-stack'}>
                            <Stack.Item>
                                <Stack horizontal className={'project-search'}>
                                    <Stack.Item className={'search-box'}>
                                    <SearchBox 
                                        className={'custom-search-box'}
                                        placeholder="Search"
                                        onChange={(_, newValue) => onSearch(newValue || '')}
                                        onSearch={onSearch}
                                        onClear={() => onSearch('')}
                                        />
                                    </Stack.Item>
                                    <Stack.Item className={'search-button'}>
                                        <DefaultButton onClick={(ev: any) => { onActionClick(ev) }} className={'secondary-button'}>{t('createNewProject')}</DefaultButton>
                                    </Stack.Item>
                                </Stack>
                            </Stack.Item>
                            <Stack.Item className={'project-items-wrapper'}>
                                    {filteredProjects.map((project: any, index: number) => {
                                        return (
                                            <Stack onClick={() => clickAction(project)} className={'project-item'} key={index}>
                                                    <Stack.Item>
                                                        <Stack horizontal className={'project-details'}>
                                                            <Stack.Item>
                                                                <Stack>
                                                                    <Stack.Item>
                                                                        <span className={'project-name'}>{project.name}</span><br/>
                                                                    </Stack.Item>
                                                                    <Stack.Item>
                                                                    <span className={'project-date'}>Created on {moment(project.created_at).format("Do MMM YY")}</span>
                                                                    </Stack.Item>
                                                                </Stack>
                                                            </Stack.Item>
                                                            <Stack.Item>
                                                                <Stack horizontal>
                                                                    <Stack.Item>
                                                                        <IconButton 
                                                                            iconProps={{iconName: 'Share'}} 
                                                                            title="Share" 
                                                                            ariaLabel="Share" 
                                                                            onClick={(ev:any) => openShareProject(project, ev)}
                                                                            />
                                                                    </Stack.Item>
                                                                    <Stack.Item>
                                                                        <IconButton iconProps={{iconName: 'Delete'}} onClick={(ev:any)=> { deleteProject(project, ev); } } title={t("delete")} ariaLabel={t("delete")} />
                                                                    </Stack.Item>
                                                                </Stack>
                                                            </Stack.Item>
                                                        </Stack>
                                                    </Stack.Item>
                                                    <Stack.Item>
                                                        <div className={'project-description'}>{project.description}</div>
                                                    </Stack.Item>
                                            </Stack>
                                        )
                                    })}
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                </Stack>
            </Stack.Item>
        </Stack>
    )

}

export default HomePage;
