import '@/styles/components/publishModal.scss';
import { DefaultButton, Icon, Label, Modal, Stack, TextField } from '@fluentui/react';
import React from 'react';
import { sendRequest } from '../../api';
import { useTranslation } from 'react-i18next';


interface props {
    isOpen: boolean,
    hideModal: Function,
    representations: any,
    dslName: string
}

const uploadProgram = (url: string, secret: string, name: string, representations: any) => {
    const dslContentText = representations?.find(r => r.name == 'dsl')?.text || '{}';
    const codeContent = representations?.find(r => r.name == 'code')?.text || ''
    const dslContent = JSON.parse(dslContentText);
    const credentials = dslContent.config_vars.map(x => x.name);
    ;

    const requestBody = {
        'name': dslContent.fsm_name,
        'dsl': dslContentText,
        'code': codeContent,
        'requirements': '',
        'required_credentials': credentials,
        'index_urls':[''],
        'version': '1.0.0'

    }

    sendRequest({
        url: url,
        method: "POST",
        accessToken: secret,
        body: JSON.stringify(requestBody),
        headers: {
            'Content-Type': 'application/json'
        }
    });
}

export const PublishModal = (props: props) => {
    const [message, setMessage] = React.useState('');
    const [secretKey, setSecretKey] = React.useState('');
    const { t } = useTranslation();
    
    const resetModal = () => {
        setMessage('');
        setSecretKey('');
        props.hideModal();
    }
    
    return(
        <>
            <Modal
                isOpen={props.isOpen}
                isBlocking={true}
                onDismiss={() => props.hideModal()}
                className={'publish-modal-container'}
            >
                <Stack className='content'>
                    <Stack.Item>
                        <span className='header'>{t('publishModal.message')}</span>
                    </Stack.Item>
                    <Stack.Item>
                        <Stack horizontal className='input-fields'>
                            <Stack.Item>
                                <Label htmlFor={'installationUrl'}>{t('publishModal.installationURL')}</Label>
                            </Stack.Item>
                            <Stack.Item>
                                <TextField 
                                    id={'installationUrl'}
                                    onChange={(e, value) => { setMessage(value || '') }}
                                    value={message}/>
                            </Stack.Item>
                        </Stack>
                        <Stack horizontal className='input-fields'>
                            <Stack.Item>
                                <Label htmlFor={'jbManagerSecret'}>{t('publishModal.installationSecret')}</Label>
                            </Stack.Item>
                            <Stack.Item>
                                <TextField 
                                    id={'jbManagerSecret'}
                                    onChange={(e, value) => { setSecretKey(value || '') }}
                                    value={secretKey}/>
                            </Stack.Item>
                        </Stack>
                        <Stack>
                            <Stack.Item>
                                <p>
                                    {t('publishModal.instruction')}
                                </p>
                            </Stack.Item>
                            <Stack.Item>
                                <p>
                                <Icon iconName="WarningSolid" />
                                    {t('publishModal.warning')}
                                </p>
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                    <Stack.Item>
                        <Stack horizontal className={'footer-buttons'}>
                            <Stack.Item>
                                <DefaultButton className={'primary-button'} onClick={() => {
                                    uploadProgram(message, secretKey, props.dslName, props.representations);
                                    resetModal();
                                }}>{t('publishModal.publishButton')}</DefaultButton>
                            </Stack.Item>
                            <Stack.Item>
                                <DefaultButton onClick={() => resetModal()}>Cancel</DefaultButton>
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                </Stack>
            </Modal>
        </>
    )
}

export default PublishModal;