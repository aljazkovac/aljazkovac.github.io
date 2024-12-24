---
title: "Understanding SSH Keys: Your Key Pair vs. Server Host Key"
date: 2024-12-24
categories: [SSH, Security]
tags: [SSH, Keys, Security]
---

A clear understanding of SSH keys is essential for secure and seamless server access. This post explains the difference between **your personal SSH key pair** and the **server’s host key**, how they work together, and why they’re critical.

---

## 1. Your Personal SSH Key Pair
This key pair identifies **you** as a trusted user.

### Key Components:
- **Private Key (e.g., `~/.ssh/id_ed25519`)**:
  - Stays on your local machine.
  - Used to prove your identity when connecting to a server.
  - **Never shared** with anyone or any server.
- **Public Key (e.g., `~/.ssh/id_ed25519.pub`)**:
  - Shared with the server (e.g., added to the `~/.ssh/authorized_keys` file on the server).
  - Used by the server to verify that you possess the corresponding private key.

### How It’s Used:
- When you connect to the server, your SSH client uses your private key to perform a cryptographic operation.
- The server validates this operation using your public key stored in its `authorized_keys` file.
- If the match is successful, the server knows you’re an authorized user and grants access.

---

## 2. The Server’s Host Key
This key pair identifies **the server** and ensures you’re connecting to the correct machine.

### Key Components:
- **Private Host Key (e.g., `/etc/ssh/ssh_host_ed25519_key`)**:
  - Stays on the server.
  - Used by the server to prove its identity to connecting clients.
  - **Never shared** with anyone.
- **Public Host Key (e.g., `/etc/ssh/ssh_host_ed25519_key.pub`)**:
  - Sent to your SSH client during the first connection.
  - Used by your client to verify the server’s identity in future connections.

### How It’s Used:
- When you connect to a server:
  - The server sends its public host key to your SSH client.
  - Your SSH client calculates the fingerprint of this key and checks it against the `~/.ssh/known_hosts` file.
  - If the key is not in `known_hosts`, SSH prompts you to verify and add it.
  - If the key matches a previously stored entry in `known_hosts`, the connection proceeds seamlessly.
  - If the key doesn’t match, SSH raises a warning (e.g., due to a server rebuild).

---

## Key Differences
| **Your SSH Keys**                            | **Server Host Keys**                           |
|----------------------------------------------|-----------------------------------------------|
| **Purpose**: Prove your identity as a user.  | **Purpose**: Prove the server’s identity.     |
| **Private Key**: Stays on your machine.      | **Private Key**: Stays on the server.         |
| **Public Key**: Shared with the server and added to `authorized_keys`. | **Public Key**: Shared with the client and added to `known_hosts`. |
| Unique to **you** as a user.                 | Unique to **the server** as a machine.        |

---

## How They Work Together
Here’s the full workflow when you SSH into the server:

1. **Server Proves Its Identity**:
  - The server sends its public host key (e.g., `ssh_host_ed25519_key.pub`) to your SSH client.
  - Your SSH client checks the fingerprint of this key:
    - If it matches an entry in `~/.ssh/known_hosts`, the server is verified.
    - If it’s a new server or the host key has changed, you’re prompted to verify and add it to `known_hosts`.
2. **You Prove Your Identity**:
  - Your SSH client uses your private key (e.g., `id_ed25519`) to perform a cryptographic operation.
  - The server checks this operation against your public key in `~/.ssh/authorized_keys`.
  - If they match, you’re granted access.

---

## Why Two Key Pairs?
The distinction ensures **mutual trust**:
- Your personal SSH key pair ensures that **only you** can access the server.
- The server’s host key ensures that **only the real server** can respond to your connection request.

This two-way verification protects against:
1. **Unauthorized Access**: Even if someone steals your public key, they can’t access the server without your private key.
2. **Man-in-the-Middle Attacks**: If someone tries to impersonate the server, the mismatch in the host key will trigger a warning.

---

## In Your Case
When you connected to the droplet:
1. The server presented its `ssh_host_ed25519_key.pub` key.
2. Your client didn’t recognize it (since it was rebuilt), so it prompted you to verify and add it to `known_hosts`.
3. After you verified and added the key, the client stored it in `~/.ssh/known_hosts` to avoid future prompts.
4. Your personal SSH key pair (`id_ed25519` and `id_ed25519.pub`) was used to authenticate you as the user.

---


