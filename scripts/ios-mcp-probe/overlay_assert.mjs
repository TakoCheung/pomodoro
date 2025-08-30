import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const serverCmd = 'node';
const serverArgs = ['/Users/takocheung/Repos/ios-simulator-mcp/build/index.js'];

function collectStrings(node, out) {
  if (node == null) return;
  if (typeof node === 'string') {
    out.push(node);
    return;
  }
  if (typeof node === 'number' || typeof node === 'boolean') return;
  if (Array.isArray(node)) {
    for (const el of node) collectStrings(el, out);
    return;
  }
  if (typeof node === 'object') {
    for (const [k, v] of Object.entries(node)) {
      if (k === 'label' || k === 'value' || k === 'AXTitle' || k === 'AXValue' || k === 'title') {
        if (typeof v === 'string') out.push(v);
      }
      collectStrings(v, out);
    }
  }
}

async function main() {
  const transport = new StdioClientTransport({ command: serverCmd, args: serverArgs });
  const client = new Client({ name: 'codex-cli', version: '0.1.0', capabilities: {} });
  await client.connect(transport);

  const toolsList = await client.listTools();
  const toolNames = toolsList.tools?.map(t => t.name) || [];
  if (!toolNames.includes('ui_describe_all')) {
    console.error('ui_describe_all not available');
    process.exit(2);
  }

  const desc = await client.callTool({ name: 'ui_describe_all', arguments: {} });
  const jsonText = desc?.content?.[0]?.text ?? '';
  let parsed;
  try {
    parsed = JSON.parse(jsonText);
  } catch (e) {
    console.error('Failed to parse UI JSON');
    process.exit(3);
  }
  const texts = [];
  collectStrings(parsed, texts);

  // Look for a verse-like reference (e.g., Genesis 1:1, John 3:16, Psalm 23:1)
  const refRegex = /(Genesis|Exodus|John|Romans|Psalm|Psalms|Proverbs|Isaiah)\s+\d+:\d+/i;
  const hit = texts.find(t => refRegex.test(t));
  if (hit) {
    console.log('FOUND_REFERENCE:', hit);
    process.exit(0);
  } else {
    console.error('No verse-like reference found in current UI');
    process.exit(4);
  }
}

main().catch(err => { console.error(err); process.exit(1); });

