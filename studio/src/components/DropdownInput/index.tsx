import '@/styles/components/publishModal.scss';
import { DefaultButton, Dropdown, Label, Stack } from '@fluentui/react';
import React from 'react';

interface props {
    choices: any,
    sendChoice: Function
}

export const DropdownInput = (props: props) => {
    const optionsList = props.choices ?? [];
    const options = optionsList.map((x, i) => ({'key': '_' + i, 'text': x}));

    if (options.length > 0) {
        options[0].selected = true;
    }

    const [selectedOption, setSelectedOption] = React.useState(0);

    const setChoice = (e, o, i) => {
        setSelectedOption(i);
    }

    const updateChoice = () => {
        if (options.length > 0)
            props.sendChoice(optionsList[selectedOption]);
    }

    return (
        <Stack className='content publish-modal-container'>
            <Stack.Item>
                <Stack>
                    <Stack.Item>
                        <Dropdown
                            label="Please select one of the options"
                            options={options}
                            onChange={setChoice} />
                    </Stack.Item>
                </Stack>
                <Stack>
                    <Stack.Item>
                        <DefaultButton onClick={updateChoice}>Submit</DefaultButton>
                    </Stack.Item>
                </Stack>
            </Stack.Item>
        </Stack>
    );
}

export default DropdownInput;