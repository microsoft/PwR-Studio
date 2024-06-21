const APIHOST = import.meta.env.VITE_REACT_APP_SERVER_HOST;
const NOAUTH = import.meta.env.VITE_REACT_APP_NO_AUTH;

const removeProtocol = (url:string) => {
    return url.replace(/^(https?:\/\/)/, "");
}

const isSecure = APIHOST.startsWith("https://");

const host = removeProtocol(APIHOST);

export const APIHost = isSecure ? `https://${host}` : `http://${host}`;
export const WebSocketHost = isSecure ? `wss://${host}` : `ws://${host}`;
export const NoAuth = NOAUTH ? true : false;

export const DefaultName = "a";
export const DefaultOID = "1";
export const DefaultEmail = "a@b.com";
export const DefaultAuthToken = "1234";
