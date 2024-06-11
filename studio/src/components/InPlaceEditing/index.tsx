import React, { useState } from 'react';
import { TextField, PrimaryButton, DefaultButton, Stack } from '@fluentui/react';

interface props {
    placeholder: string;
    text: string|undefined;
    onTextChange: (text:string|undefined) => void;
}

function InPlaceEditing(props:props) {
  const [editing, setEditing] = useState(false);
  const [editedText, setEditedText] = useState(props.text);

  const handleEditButtonClick = () => {
    setEditing(true);
  };

  const handleSaveButtonClick = () => {
    props.onTextChange(editedText);
    setEditing(false);
  };

  const handleCancelButtonClick = () => {
    setEditedText(props.text);
    setEditing(false);
  };

  const handleEditedTextChange = (event:any) => {
    setEditedText(event.target.value);
  };

  return (
    <div>
      {editing ? (
        <Stack horizontal tokens={{childrenGap: 5}}>
          <Stack.Item>
            <TextField style={{width: 250}} value={editedText} onChange={handleEditedTextChange} />
          </Stack.Item>
          <Stack.Item>
            <PrimaryButton onClick={handleSaveButtonClick}>Save</PrimaryButton>&nbsp;&nbsp;
            <DefaultButton onClick={handleCancelButtonClick}>Cancel</DefaultButton>
          </Stack.Item>
        </Stack>
      ) : (
        <div onClick={handleEditButtonClick} style={{cursor: 'pointer'}}>
          <span>{props.text ? props.text : props.placeholder}</span>
        </div>
      )}
    </div>
  );
}

export default InPlaceEditing;