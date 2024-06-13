import React from 'react';
import ReactDOM from 'react-dom';
import { mergeStyles } from '@fluentui/react';
import { initializeIcons } from '@fluentui/react/lib/Icons';
import { PublicClientApplication } from "@azure/msal-browser";
import { MsalProvider, AuthenticatedTemplate, UnauthenticatedTemplate } from "@azure/msal-react";
import {
  createHashRouter,
  RouterProvider,
} from "react-router-dom";
import reportWebVitals from './reportWebVitals';
import { App, HomePage, EditorPage } from './pages';
import { AppInsightsContext } from '@microsoft/applicationinsights-react-js';
import { reactPlugin } from './applicationInsightsService';
import { msalConfig } from "./authConfig";
import './i18n';

const msalInstance = new PublicClientApplication(msalConfig);

const authenticatedRouter = createHashRouter([
  {
    path: "/",
    element: <App/>,
  },
  {
    path: "/home",
    element: <HomePage/>,
  },
  {
    path: "/editor/:id",
    element: <EditorPage/>,
  }
]);

const unAuthenticatedRouter = createHashRouter([
  {
    path: "/",
    element: <App/>,
  }
]);

// Inject some global styles
mergeStyles({
  ':global(body,html,#root)': {
    margin: 0,
    padding: 0,
    height: '100vh',
  },
});

initializeIcons();

ReactDOM.render(
  <React.StrictMode>
    <MsalProvider instance={msalInstance}>
    <AuthenticatedTemplate>
      <AppInsightsContext.Provider value={reactPlugin ? reactPlugin : {}}>
        <RouterProvider router={authenticatedRouter} />
      </AppInsightsContext.Provider>
    </ AuthenticatedTemplate>
    <UnauthenticatedTemplate>
      <AppInsightsContext.Provider value={reactPlugin ? reactPlugin : {}}>
        <RouterProvider router={unAuthenticatedRouter} />
      </AppInsightsContext.Provider>
    </UnauthenticatedTemplate>
    </MsalProvider>
  </React.StrictMode>, 
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
