import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import fs from 'fs';
import path from 'path';

const serverCmd = 'node';
const serverArgs = ['/Users/takocheung/Repos/ios-simulator-mcp/build/index.js'];

async function main() {
  const transport = new StdioClientTransport({ command: serverCmd, args: serverArgs });
  const client = new Client({
    name: 'codex-cli',
    version: '0.1.0',
    capabilities: {}
  });

  await client.connect(transport);

  const toolsList = await client.listTools();
  const toolNames = toolsList.tools?.map(t => t.name) || [];
  console.log('TOOLS:', toolNames.join(', '));

  if (!toolNames.includes('get_booted_sim_id')) {
    console.error('get_booted_sim_id tool not available');
    process.exit(2);
  }

  const result = await client.callTool({ name: 'get_booted_sim_id', arguments: {} });
  console.log('CALL_RESULT:', JSON.stringify(result, null, 2));

  // Also take a screenshot to verify functional access
  const outPath = new URL('../../artifacts/ios/sim_screenshot.png', import.meta.url).pathname;
  // Ensure directory exists
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  const shot = await client.callTool({ name: 'screenshot', arguments: { output_path: outPath } });
  console.log('SCREENSHOT:', JSON.stringify(shot, null, 2));
  console.log('Saved screenshot to', outPath);

  // Describe the full UI tree and save it
  const desc = await client.callTool({ name: 'ui_describe_all', arguments: {} });
  const uiJson = desc?.content?.[0]?.text ?? '';
  const uiOut = new URL('../../artifacts/ios/ui_describe_all.json', import.meta.url).pathname;
  fs.mkdirSync(path.dirname(uiOut), { recursive: true });
  fs.writeFileSync(uiOut, uiJson, 'utf8');
  console.log('Saved UI description to', uiOut);

  // Try a tap near the top-left corner
  const tap = await client.callTool({ name: 'ui_tap', arguments: { x: 100, y: 100 } });
  console.log('TAP_RESULT:', JSON.stringify(tap, null, 2));

  // Try typing basic text (if any text field is focused)
  const typed = await client.callTool({ name: 'ui_type', arguments: { text: 'Hello' } });
  console.log('TYPE_RESULT:', JSON.stringify(typed, null, 2));

  await client.close();
}

main().catch(err => { console.error(err); process.exit(1); });
