const { spawn } = require('child_process');
const fs = require('fs');

function log(msg) {
    fs.appendFileSync('debug.log', msg + '\n');
}

log('Starting script...');

const project = '9064173060952920822';
const screen = '0de1011c822545578e13a2c276b64e8c';
const env = { ...process.env };
env.GOOGLE_CLOUD_PROJECT = 'numeric-replica-487322-d7';
log('Testing with numeric-replica-487322-d7...');
env.STITCH_API_KEY = 'AQ.Ab8RN6IHpXAotuMm8EtricTAGCZEQgDxHqWmFUZhW3i7NhIuiw';

const client = spawn('npx', ['-y', 'stitch-mcp'], { env });

let buffer = '';

client.stdout.on('data', (data) => {
    log(`stdout data: ${data}`);
    buffer += data.toString();
    processBuffer();
});

client.stderr.on('data', (data) => {
    log(`stderr: ${data}`);
});

client.on('exit', (code) => {
    log(`Child exited with code ${code}`);
});

client.on('error', (err) => {
    log(`Failed to start child process: ${err}`);
});

function processBuffer() {
    const lines = buffer.split('\n');
    buffer = lines.pop(); // Keep the last partial line

    for (const line of lines) {
        if (!line.trim()) continue;
        try {
            const msg = JSON.parse(line);
            handleMessage(msg);
        } catch (e) {
            log(`Failed to parse (might be logs): ${line}`);
        }
    }
}

let step = 0;

function send(msg) {
    const str = JSON.stringify(msg) + '\n';
    log(`Sending: ${str.trim()}`);
    client.stdin.write(str);
}

function handleMessage(msg) {
    log(`Received message: ${JSON.stringify(msg)}`);
    if (msg.id === 0 && step === 0) {
        // Initialized response
        log('Initialized');
        send({
            jsonrpc: '2.0',
            method: 'notifications/initialized'
        });

        // Call list_projects
        log('Calling list_projects...');
        send({
            jsonrpc: '2.0',
            id: 1,
            method: 'tools/call',
            params: {
                name: 'list_projects',
                arguments: {}
            }
        });
        step = 1;

    } else if (msg.id === 1 && step === 1) {
        // Response for list_projects
        log(`list_projects Response: ${JSON.stringify(msg.result, null, 2)}`);

        if (msg.result && msg.result.content && msg.result.content.length > 0) {
            const content = msg.result.content[0].text;
            fs.writeFileSync('projects_list.txt', content);
            log('Saved projects list to projects_list.txt');
        } else {
            fs.writeFileSync('projects_list.json', JSON.stringify(msg.result, null, 2));
        }

        // Call fetch_screen_code
        log('Calling fetch_screen_code...');
        send({
            jsonrpc: '2.0',
            id: 2,
            method: 'tools/call',
            params: {
                name: 'fetch_screen_code',
                arguments: {
                    projectId: project,
                    screenId: screen
                }
            }
        });
        step = 2;
    } else if (msg.id === 2 && step === 2) {
        // Response for fetch_screen_code
        log(`fetch_screen_code Response: ${JSON.stringify(msg.result, null, 2)}`);
        fs.writeFileSync('screen_code_output.txt', JSON.stringify(msg.result, null, 2));
        log('Saved screen code to screen_code_output.txt');

        // Call fetch_screen_image
        log('Calling fetch_screen_image...');
        send({
            jsonrpc: '2.0',
            id: 3,
            method: 'tools/call',
            params: {
                name: 'fetch_screen_image',
                arguments: {
                    projectId: project,
                    screenId: screen
                }
            }
        });
        step = 3;
    } else if (msg.id === 3 && step === 3) {
        // Response for fetch_screen_image
        log(`fetch_screen_image Response: ${JSON.stringify(msg.result, null, 2)}`);
        fs.writeFileSync('screen_image_output.txt', JSON.stringify(msg.result, null, 2));
        log('Saved screen image to screen_image_output.txt');
        log('Done.');
        process.exit(0);
    }
}

// Start sequence
send({
    jsonrpc: '2.0',
    id: 0,
    method: 'initialize',
    params: {
        protocolVersion: '2024-11-05',
        capabilities: {},
        clientInfo: { name: 'script', version: '1.0' }
    }
});
