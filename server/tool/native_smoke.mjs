// Prüft die tatsächlich kompilierte Server-Datei, nicht dart run oder eine Fake-Runtime.
// Node 22: nur eingebaute Werkzeuge, keine zusätzlichen Pakete.
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = fileURLToPath(new URL('../../', import.meta.url));
let stage = 'Start';

async function pruefen() {
  const child = spawn(path.join(root, '.werkzeug/server-pruefung'), [], {
    cwd: root,
    env: {
      ...process.env, PORT: '0', TRUST_PROXY: '0',
      SCENARIO_DIR: path.join(root, 'content/scenarios'),
      PARTY_DIR: path.join(root, 'content/party/schlosskeller'),
    },
    // Server-Rohlogs nicht ausgeben: nur die expliziten Prüfresultate unten.
    stdio: ['ignore', 'pipe', 'ignore'],
  });
  const exited = new Promise(resolve => child.once('exit', resolve));
  let socket;
  try {
    const port = await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error('Startzeitlimit')), 15000);
      child.once('error', () => { clearTimeout(timer); reject(new Error('Startfehler')); });
      let text = '';
      child.stdout.on('data', chunk => {
        text = (text + chunk.toString()).slice(-8192);
        const match = text.match(/Server lauscht auf :(\d+)/);
        if (match) { clearTimeout(timer); resolve(Number(match[1])); }
      });
    });
    stage = 'Healthcheck';
    const health = await fetch(`http://127.0.0.1:${port}/health`, { signal: AbortSignal.timeout(5000) });
    if (health.status !== 200 || !(await health.text()).startsWith('ok rooms=')) throw new Error('Healthcheck');
    stage = 'WebSocket';
    socket = new WebSocket(`ws://127.0.0.1:${port}/ws`);
    const messages = [], waiting = [];
    function receive(type, predicate = () => true) {
      return new Promise((resolve, reject) => {
        const entry = { type, predicate, resolve, reject, timer: setTimeout(() => reject(new Error('Nachricht fehlt')), 5000) };
        waiting.push(entry); flush();
      });
    }
    function flush() {
      for (let i = waiting.length - 1; i >= 0; i--) {
        const entry = waiting[i];
        const index = messages.findIndex(m => m.t === entry.type && entry.predicate(m));
        if (index !== -1) {
          waiting.splice(i, 1); clearTimeout(entry.timer);
          entry.resolve(messages.splice(index, 1)[0]);
        }
      }
    }
    socket.addEventListener('message', event => {
      try { messages.push(JSON.parse(event.data)); flush(); }
      catch {
        for (const entry of waiting) { clearTimeout(entry.timer); entry.reject(new Error('Ungültige Nachricht')); }
        waiting.length = 0;
        socket.close(1002);
      }
    });
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error('Socketzeitlimit')), 5000);
      socket.addEventListener('open', () => { clearTimeout(timer); resolve(); }, { once: true });
      socket.addEventListener('error', () => { clearTimeout(timer); reject(new Error('Socketfehler')); }, { once: true });
    });
    stage = 'Anmeldung und Partyraum';
    socket.send(JSON.stringify({ t: 'hello', name: 'Native-Probe', proto: 1 }));
    const welcome = await receive('welcome');
    socket.send(JSON.stringify({ t: 'create', abend: 'schlosskeller' }));
    const room = await receive('room');
    const lobby = await receive('abend', m => m.phase === 'lobby');
    if (room.abend !== 'schlosskeller' || lobby.privat.spieler !== welcome.player) throw new Error('Falsche Ansicht');
    stage = 'Start und Rollenansicht';
    socket.send(JSON.stringify({ t: 'abend_cmd', c: { typ: 'bereit', wert: true } }));
    socket.send(JSON.stringify({ t: 'abend_cmd', c: { typ: 'start', rollen: 4 } }));
    const roles = await receive('abend', m => m.phase === 'rollen');
    if (roles.rollen !== 4 || 'dossier' in roles.privat) throw new Error('Falsche Rollenansicht');
    socket.send(JSON.stringify({ t: 'leave' }));
  } finally {
    socket?.close(1000);
    if (child.pid) {
      child.kill('SIGTERM');
      const code = await Promise.race([exited, new Promise((_, reject) => {
        const timer = setTimeout(() => reject(new Error('Beenden überschritt Zeitlimit')), 5000);
        timer.unref();
      })]);
      if (code !== 0) throw new Error('Server nicht sauber beendet');
    }
  }
}

try {
  await pruefen();
  console.log('AOT-SERVER GRÜN · HTTP 200 · echte WebSocket-Anmeldung · Partyraum · Start mit Botrollen · eigene Ansicht · sauber beendet');
} catch {
  // Keine Rohpakete, Tokens, privaten Karten, Konfiguration oder Prozessausgaben.
  console.error(`AOT-SERVER ROT · Schritt: ${stage}`);
  process.exitCode = 1;
}
