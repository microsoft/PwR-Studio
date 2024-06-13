import { ApplicationInsights, ITelemetryItem } from '@microsoft/applicationinsights-web';
import { ReactPlugin } from '@microsoft/applicationinsights-react-js';

const instrumentationKey = import.meta.env.VITE_REACT_APP_INSIGHTS_KEY;
let appInsights: ApplicationInsights | null = null;
let reactPlugin: ReactPlugin | null = null;

if (instrumentationKey) {
  reactPlugin = new ReactPlugin();
  appInsights = new ApplicationInsights({
    config: {
      instrumentationKey: instrumentationKey,
      extensions: [reactPlugin],
      extensionConfig: {},
      enableAutoRouteTracking: true,
      disableAjaxTracking: false,
      autoTrackPageVisitTime: true,
      enableCorsCorrelation: true,
      enableRequestHeaderTracking: true,
      enableResponseHeaderTracking: true
    }
  });
  appInsights.loadAppInsights();

  appInsights.addTelemetryInitializer((env:ITelemetryItem) => {
      env.tags = env.tags || [];
      env.tags["ai.cloud.role"] = "testTag";
  });
}

export { reactPlugin, appInsights };
