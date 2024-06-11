import { LogLevel } from "@azure/msal-browser";
const TENANT_ID = import.meta.env.VITE_REACT_APP_AAD_APP_TENANT_ID;
const CLIENT_ID = import.meta.env.VITE_REACT_APP_AAD_APP_CLIENT_ID;
const SCOPE_URI = import.meta.env.VITE_REACT_APP_ADD_APP_SCOPE_URI;
export const msalConfig:any = {
    auth: {
        clientId:  `${CLIENT_ID}`, 
        authority: `https://login.microsoftonline.com/${TENANT_ID}`,
        postLogoutRedirectUri:  '/', 
        navigateToLoginRequestUrl: true, 
    },
    cache: {
        cacheLocation: "sessionStorage", 
        storeAuthStateInCookie: false
    },
    scopes: [
        SCOPE_URI
    ],
    system: {
        loggerOptions: {
            loggerCallback: (level: any, message:string, containsPii:any) => {
                if (containsPii) {
                    return;
                }
                switch (level) {
                    case LogLevel.Error:
                        console.error(message);
                        return;
                    case LogLevel.Info:
                        console.info(message);
                        return;
                    case LogLevel.Verbose:
                        console.debug(message);
                        return;
                    case LogLevel.Warning:
                        console.warn(message);
                        return;
                }
            }
        }
    }
};
