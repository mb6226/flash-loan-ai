require('dotenv').config();
const { spawn } = require('child_process');
const path = require('path');

const cwd = process.cwd();

function startProcess(command, args, name) {
  console.log(`[INFO] Starting ${name}: ${command} ${args.join(' ')}`);
  const proc = spawn(command, args, { cwd, stdio: 'inherit', shell: true });
  proc.on('error', (err) => console.error(`[ERROR] ${name} process error:`, err));
  proc.on('exit', (code, signal) => console.log(`[INFO] ${name} exited with code=${code} signal=${signal}`));
  return proc;
}

function main() {
  // Start Python inference
  const p1 = startProcess('python', ['-m', 'src.ai.inference'], 'inference');
  // Start Node listeners
  const p2 = startProcess('node', [path.join('src', 'blockchain', 'listeners.js')], 'listeners');
  // Start Node mempool monitor
  const p3 = startProcess('node', [path.join('src', 'blockchain', 'mempool_monitor.js')], 'mempool_monitor');

  const procs = [p1, p2, p3];

  process.on('SIGINT', () => {
    console.log('[INFO] Stopping processes...');
    procs.forEach((p) => { if (p && !p.killed) p.kill('SIGINT'); });
    process.exit();
  });
}

main();
