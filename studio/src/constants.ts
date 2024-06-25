const APIHOST = import.meta.env.VITE_REACT_APP_SERVER_HOST;

const removeProtocol = (url:string) => {
    return url.replace(/^(https?:\/\/)/, "");
}

const isSecure = APIHOST.startsWith("https://");

const host = removeProtocol(APIHOST);

export const APIHost = isSecure ? `https://${host}` : `http://${host}`;
export const WebSocketHost = isSecure ? `wss://${host}` : `ws://${host}`;
