# Downloads all .json files from positron/comms/ in the posit-dev/positron
# GitHub repo into resources/positron-comms/.

import json
import os
import urllib.request

repo = "posit-dev/positron"
remote_dir = "positron/comms"
dest_dir = "resources/positron-comms"

os.makedirs(dest_dir, exist_ok=True)

api_url = f"https://api.github.com/repos/{repo}/contents/{remote_dir}"

req = urllib.request.Request(
    api_url,
    headers={"Accept": "application/vnd.github+json"},
)
with urllib.request.urlopen(req) as resp:
    listing = json.load(resp)

files = [
    entry
    for entry in listing
    if entry.get("type") == "file"
    and entry["name"].endswith(".json")
    and entry["name"] not in ["package-lock.json", "package.json"]
]

for entry in files:
    dest = os.path.join(dest_dir, entry["name"])
    print(f"Downloading {entry['name']} -> {dest}")
    urllib.request.urlretrieve(entry["download_url"], dest)

print(f"Downloaded {len(files)} file(s) into {dest_dir}")
