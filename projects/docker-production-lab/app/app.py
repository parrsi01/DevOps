import os
import socket
from datetime import datetime
from flask import Flask, jsonify

app = Flask(__name__)
DATA_DIR = os.getenv("DATA_DIR", "/data")
COUNTER_FILE = os.path.join(DATA_DIR, "hits.txt")


def read_hits():
    try:
        with open(COUNTER_FILE, "r", encoding="utf-8") as f:
            return int(f.read().strip() or "0")
    except FileNotFoundError:
        return 0


def write_hits(value: int):
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(COUNTER_FILE, "w", encoding="utf-8") as f:
        f.write(str(value))


@app.get("/")
def index():
    hits = read_hits() + 1
    write_hits(hits)
    return jsonify(
        {
            "message": "Docker production lab",
            "hits": hits,
            "hostname": socket.gethostname(),
            "time": datetime.utcnow().isoformat() + "Z",
        }
    )


@app.get("/health")
def health():
    return jsonify({"status": "ok"}), 200
