import { TextField, IconButton, IButtonStyles, ITextFieldStyles } from "@fluentui/react";
import React from "react";

interface props {
  value: string | undefined
  label: string | any
  onChange: (event:any, value:any) => void;
}
export const PasswordTextField = (options:props) => {
    const [password, setPassword] = React.useState(options.value || '');
    const [showPassword, setShowPassword] = React.useState(false);
  
    const handlePasswordChange = (event:any) => {
      setPassword(event.target.value);
      options.onChange(event, event.target.value);
    };
  
    const handleTogglePasswordVisibility = () => {
      setShowPassword(!showPassword);
    };

    const textFieldStyles: Partial<ITextFieldStyles> = {
      'suffix': {
        'overflow': 'hidden'
      }
    }
    
    const buttonStyles: Partial<IButtonStyles> = {
      root: {
        selectors: {
          ':hover': {
            backgroundColor: 'transparent'
          }
        }
      }
    }
    return (
      <TextField
        type={showPassword ? "text" : "password"}
        label={options.label}
        canRevealPassword={true}
        value={password}
        styles={textFieldStyles}
        onChange={handlePasswordChange}
        rows={2}
        revealPasswordAriaLabel="Show password"
        onRenderSuffix={(props, render) => (
          <IconButton
            iconProps={{ iconName: showPassword ? 'Hide' : 'RedEye' }}
            title={showPassword ? 'Hide password' : 'Show password'}
            ariaLabel={showPassword ? 'Hide password' : 'Show password'}
            onClick={handleTogglePasswordVisibility}
            styles={buttonStyles}
          />
        )}
      />
    );
  };

export default PasswordTextField;
