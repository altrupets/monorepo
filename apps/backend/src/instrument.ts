import * as Sentry from "@sentry/nestjs"
import { nodeProfilingIntegration } from "@sentry/profiling-node";

Sentry.init({
  dsn: "https://c728dbec15b7fb40b195781b677bb255@o4510946376876032.ingest.us.sentry.io/4510946477539328",
  integrations: [
    nodeProfilingIntegration(),
  ],

  enableLogs: true,
  tracesSampleRate: 1.0,
  profileSessionSampleRate: 1.0,
  profileLifecycle: 'trace',
  sendDefaultPii: true,
});
