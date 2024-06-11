import React from 'react';
import { Stack, Text, Icon, IconButton, getTheme, PrimaryButton, DefaultButton } from '@fluentui/react';

const PluginCard = ({ plugin, pluginCallback }:any) => {
    const [expanded, setExpanded] = React.useState(true);
    const { palette } = getTheme();

    const copyToClipboard = (e: Event, text:string) => {
        e.stopPropagation();
        e.preventDefault();
        pluginCallback(text);
    };


    return (
        <Stack tokens={{ childrenGap: 10 }} style={{ border: `1px solid ${palette.neutralLight}`, padding: 10, margin: 10, minWidth: 300, maxWidth: 300 }} onClick={() => setExpanded(!expanded)}>
            <Stack horizontal style={{justifyContent: 'space-between'}} tokens={{ childrenGap: 10 }} verticalAlign="center">
                <img style={{width: 90, height: 90}} src={plugin.icon} alt={plugin.name} />
                <Text>{plugin.name}</Text>
                <IconButton iconProps={{ iconName: expanded ? 'ChevronUp' : 'ChevronDown' }}  />
            </Stack>
            {expanded && (
                <Stack horizontal tokens={{ childrenGap: 20 }}>
                    {/* <Stack.Item align="center">
                        <img src={plugin.icon} alt={plugin.name} />
                    </Stack.Item> */}
                    <Stack.Item grow>
                        <Text>{plugin.description}</Text><br/><br/>
                        {/* <Text><a href={plugin.pypi_url}>PyPi URL</a></Text><br/><br/> */}
                        {/* <Text><a href={plugin.dsl}>DSL</a></Text><br/><br/>
                        <Text><a href={plugin.doc}>Doc</a></Text><br/><br/> */}
                        <DefaultButton className='secondary-button' text="Add" onClick={(e: any) => copyToClipboard(e, "#plugin(" + plugin.pypi_url + ")")} />
                    </Stack.Item>
                </Stack>
            )}
        </Stack>
    );
};

const PluginList = ({ plugins, pluginCallback }:any) => {
    return (
        <Stack horizontal wrap tokens={{ childrenGap: 10 }}>
            {plugins?.map((plugin:any, index:number) => (
                <PluginCard key={index} plugin={plugin.plugin} pluginCallback={pluginCallback} />
            ))}
        </Stack>
    );
};

export default PluginList;
