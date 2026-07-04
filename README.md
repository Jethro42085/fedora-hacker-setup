# fedora-hacker-setup

Scripts to turn a fresh Fedora install into a security research / pentest lab
/ CTF workstation.

> **Authorized use only.** These scripts install offensive security tooling
> (exploitation frameworks, wireless auditing tools, password crackers,
> network scanners, etc.). Only use them against systems and networks you
> own or are explicitly authorized to test. You are responsible for
> complying with all applicable laws and the terms of any engagement you're
> working under.

## What it does

`install.sh` installs tooling in independent categories so you only pull in
what you need:

| Category       | Contents                                                        |
|-----------------|------------------------------------------------------------------|
| `base`          | System upgrade, build tools, Python/Go/Rust toolchains, pipx     |
| `recon`         | nmap, masscan, wireshark, subfinder, httpx, naabu, amass, theHarvester |
| `web`           | nikto, sqlmap, gobuster, ffuf, OWASP ZAP, wfuzz                  |
| `exploitation`  | Metasploit Framework, pwntools, impacket, ropper                 |
| `wireless`      | aircrack-ng, reaver, macchanger                                  |
| `forensics`     | binwalk, foremost, sleuthkit, exiftool, testdisk, volatility3    |
| `reversing`     | radare2, gdb, ghidra, strace, ltrace                             |
| `passwords`     | john, hashcat, hydra, seclists                                   |
| `shell`         | zsh + oh-my-zsh + tmux config (quality-of-life, not security tooling) |

Each category is independent — `scripts/<category>.sh` can also be run
directly, e.g. `./scripts/recon.sh`.

Package installs are best-effort: if one package fails, the script logs it
and keeps going, then prints a summary of everything that failed at the end.

## Usage

```sh
git clone https://github.com/<you>/fedora-hacker-setup.git
cd fedora-hacker-setup

./install.sh              # interactive menu
./install.sh --all        # install everything
./install.sh --list       # show available categories
./install.sh recon web    # install specific categories
```

Run it as your normal user (not root) — it calls `sudo` itself wherever
needed.

## Requirements

- Fedora (tested against current releases; other dnf-based distros may
  mostly work but aren't officially supported)
- A user with `sudo` access
- Internet access (dnf, COPR, pipx, go install, and the oh-my-zsh installer
  all fetch things over the network)

## Notes

- Metasploit Framework comes from the `curl/metasploit-framework` COPR repo.
- Burp Suite Community isn't packaged for Fedora; download it manually from
  [PortSwigger](https://portswigger.net/burp/communitydownload).
- `scripts/lib/common.sh` holds the shared logging/install helpers used by
  every category script.

## License

MIT, see [LICENSE](LICENSE).
