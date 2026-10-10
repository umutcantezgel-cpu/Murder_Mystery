// Gemeinsamer Browserstart. Standard ist das von Playwright verwaltete Chromium.
// Ein expliziter Pfad ist nur für vorhandene lokale Installationen nötig.
import { chromium } from 'playwright';

export function browserOptionen(env = process.env) {
  const executablePath = env.MORDAKTE_CHROMIUM?.trim();
  const libraryPath = env.MORDAKTE_BROWSER_LIBRARY_PATH?.trim();
  return {
    headless: true,
    ...(executablePath ? { executablePath } : {}),
    // Lokal entpackte native Bibliotheken dürfen nicht an Flutter-Tests gehen.
    ...(libraryPath ? { env: { ...env, LD_LIBRARY_PATH: libraryPath } } : {}),
  };
}

export function starteBrowser() {
  return chromium.launch(browserOptionen());
}
