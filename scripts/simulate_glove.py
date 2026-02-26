import asyncio
import websockets
import time
import math
import argparse
import sys
import select

# Default stable hand state (flat open hand)
# F1-F5: 0-1023 (Open ~ 800, Closed ~ 300)
# GX, GY: degrees/sec
# HR: 60-120 BPM
state = {
    'f1': 800, 'f2': 800, 'f3': 800, 'f4': 800, 'f5': 800,
    'gx': 0.0, 'gy': 0.0,
    'hr': 75
}

# Pre-defined mock gestures
GESTURES = {
    'open': {'f1': 800, 'f2': 800, 'f3': 800, 'f4': 800, 'f5': 800},
    'fist': {'f1': 300, 'f2': 300, 'f3': 300, 'f4': 300, 'f5': 300},
    'point': {'f1': 300, 'f2': 800, 'f3': 300, 'f4': 300, 'f5': 300},
    'peace': {'f1': 300, 'f2': 800, 'f3': 800, 'f4': 300, 'f5': 300},
}

def get_current_state_csv(time_t):
    """Generates the CSV string with slight noise added to simulate real sensors."""
    # Add slight sine-wave noise to flex sensors (+/- 10)
    noise = int(math.sin(time_t * 5) * 10)
    
    # Format: <F1,F2,F3,F4,F5,GX,GY,HR>
    csv = f"<{state['f1']+noise},{state['f2']+noise},{state['f3']+noise},{state['f4']+noise},{state['f5']+noise},{state['gx']:.2f},{state['gy']:.2f},{state['hr']}>"
    return csv

async def stream_data(websocket):
    print(f"[Client Connected] Streaming mock data to {websocket.remote_address}")
    try:
        start_time = time.time()
        while True:
            # Check for non-blocking standard input (CLI commands)
            if sys.platform != 'win32':
                # select works on Unix-like
                i, _, _ = select.select([sys.stdin], [], [], 0.0)
                if i:
                    cmd = sys.stdin.readline().strip().lower()
                    process_cmd(cmd)
            
            # Send data at 50Hz (0.02s)
            current_time = time.time() - start_time
            csv_data = get_current_state_csv(current_time)
            
            await websocket.send(csv_data)
            await asyncio.sleep(0.02)
            
    except websockets.exceptions.ConnectionClosed:
        print(f"[Client Disconnected] {websocket.remote_address}")

def process_cmd(cmd):
    global state
    if cmd in GESTURES:
        print(f"--> Switching to gesture: {cmd.upper()}")
        state.update(GESTURES[cmd])
    elif cmd.startswith('hr '):
        try:
            new_hr = int(cmd.split(' ')[1])
            state['hr'] = new_hr
            print(f"--> Heart rate set to: {new_hr}")
        except:
            print("Invalid format. Use: hr 85")
    else:
        print(f"Unknown command: '{cmd}'. Try: 'open', 'fist', 'point', 'peace', 'hr <bpm>'")

async def main():
    parser = argparse.ArgumentParser(description="SYNAPSE Mock Glove Generator")
    parser.add_argument("--port", type=int, default=81, help="WebSocket port (default: 81)")
    args = parser.parse_args()

    print(f"Starting SYNAPSE Mock Glove Server on ws://localhost:{args.port}...")
    print("---------------------------------------------------------")
    print("Available Commands (type directly in console):")
    print("- Gestures: 'open', 'fist', 'point', 'peace'")
    print("- Vitals:   'hr 85'")
    print("---------------------------------------------------------")

    async with websockets.serve(stream_data, "localhost", args.port):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nServer shutting down.")
