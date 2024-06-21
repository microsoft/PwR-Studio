import React from 'react';
import { Stack, Text, Link, FontWeights, IStackTokens, IStackStyles, ITextStyles, DefaultPalette, ILinkStyles } from '@fluentui/react';
import '../styles/App.css';
import { AuthenticatedTemplate, UnauthenticatedTemplate, useMsal } from "@azure/msal-react";
import { EventType } from "@azure/msal-browser";
import { sendRequest } from './../api';
import { APIHost, NoAuth, DefaultName, DefaultOID, DefaultEmail, DefaultAuthToken } from './../constants';
import { useTranslation } from 'react-i18next';


const boldStyle: Partial<ITextStyles> = { root: { fontWeight: FontWeights.semibold } };
const stackTokens: IStackTokens = { childrenGap: 15 };
const linkStyle: Partial<ILinkStyles> = {
  root: {
    textDecoration: 'underline',
    color: '#0060ab'
  }
}
const stackStyles: Partial<IStackStyles> = {
  root: {
    background: DefaultPalette.themeLight,
    width: '100vw',
    margin: '0 auto',
    textAlign: 'center'
  }
};

if (NoAuth) {
  const data = {
    oid: DefaultOID,
    name: DefaultName,
    email: DefaultEmail
  }
  sendRequest({
    method: "POST",
    headers: {
  	"Content-Type": 'application/json'
    },
    body: JSON.stringify(data),
    url: `${APIHost}/users`,
    accessToken: DefaultAuthToken
  });
}

export const App: React.FunctionComponent = () => {
  const { instance } = useMsal();
  const { t } = useTranslation();
  React.useEffect(() => {
    // This will be run on component mount
    const callbackId = instance.addEventCallback((message: any) => {
      // This will be run every time an event is emitted after registering this callback
      if (NoAuth) {
	    console.log("user already added at start");
	  }
	  else {
	    if (message.eventType === EventType.LOGIN_SUCCESS) {
          const result = message.payload;
          const tokenClaims = result.account.idTokenClaims
          const data = {
            oid: tokenClaims.oid,
            name: tokenClaims.name,
            email: tokenClaims.preferred_username
          }
          sendRequest({
            method: "POST",
            headers: {
              "Content-Type": 'application/json'
            },
            body: JSON.stringify(data),
            url: `${APIHost}/users`,
            accessToken: result.accessToken
          })
            .then(response => {
              window.location.href = '/#/home'
              console.log(response)
            })
        }
	  }
    });

    return () => {
      if (callbackId) {
        instance.removeEventCallback(callbackId);
      }
    }

  }, []);
  const footer:React.CSSProperties = {
    listStyle: 'none',
    display: 'inline-block',
    padding: 10,
  }

  const login = (event: React.MouseEvent<HTMLAnchorElement | HTMLElement | HTMLButtonElement, MouseEvent>) => {
    event.preventDefault();
    instance.loginPopup({ scopes: [import.meta.env.VITE_REACT_APP_ADD_APP_SCOPE_URI || ''] }).then((response) => {
      console.log(response)
    }).catch((error) => {
      console.log(error)
    })
  }

  if (NoAuth) {
        return (
      <Stack horizontalAlign="center" verticalAlign="center" verticalFill styles={stackStyles} tokens={stackTokens}>
        <Text variant="xxLarge" styles={boldStyle}>
          Welcome to PwR Studio
        </Text>
        <Stack styles={{ root: { width: "80vw" } }} >
          <Text variant="large">
            Programming with Representations (<b>PwR</b>) gives you the ability to build applications using a conversational interface. Build anything you like just by describing it in plain English.
          </Text>
        </Stack>
        <br />
        <br />
          <Stack verticalAlign='center' styles={{ root: { width: "80vw" } }} >
            <br />
            <br />
            <Text variant="large">
              Click on <Link styles={linkStyle} href="#/home">My Projects</Link> to access your projects
            </Text>
            <br />
            <br />
          </Stack>
        <footer>
          <div>
            <ul style={footer}>
            </ul>
          </div>
        </footer>
      </Stack >
    );
  }
  else {
    return (
      <Stack horizontalAlign="center" verticalAlign="center" verticalFill styles={stackStyles} tokens={stackTokens}>
        <Text variant="xxLarge" styles={boldStyle}>
          Welcome to PwR Studio
        </Text>
        <Stack styles={{ root: { width: "80vw" } }} >
          <Text variant="large">
            Programming with Representations (<b>PwR</b>) gives you the ability to build applications using a conversational interface. Build anything you like just by describing it in plain English.
          </Text>
        </Stack>
        <br />
        <br />
        <AuthenticatedTemplate>
          <Stack verticalAlign='center' styles={{ root: { width: "80vw" } }} >
            <br />
            <br />
            <Text variant="large">
              Click on <Link styles={linkStyle} href="#/home">My Projects</Link> to access your projects
            </Text>
            <br />
            <br />
          </Stack>
        </AuthenticatedTemplate>
        <UnauthenticatedTemplate>
          <Link styles={linkStyle} href="#" onClick={login}>{t('login')}</Link>
        </UnauthenticatedTemplate>
        <AuthenticatedTemplate>
          <Link styles={linkStyle} href="#" onClick={() => instance.logoutPopup()}>{t('logout')}</Link>
        </AuthenticatedTemplate>
        <footer>
          <div>
            <ul style={footer}>
            </ul>
          </div>
        </footer>
      </Stack >
    );
  }
};