---
title: "Understanding SSH Keys: Your Key Pair vs. Server Host Key"
date: 2024-12-24
categories: [SSH, Security]
tags: [SSH, Keys, Security]
---

A clear understanding of SSH keys is essential for secure and seamless server access. This post explains the difference between 
**your personal SSH key pair** and the **server’s host key**, how they work together, and why they’re critical.

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

## The `ifconfig` Command
The `ifconfig` command is a powerful tool for managing and inspecting network interfaces on a server or local machine. Here's what it does and how you can use it:

### Purpose:
- View the current network configuration of your server or machine.
- Enable, disable, or configure network interfaces.

### Example Output:
```plaintext
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
    inet 206.189.100.37  netmask 255.255.240.0  broadcast 206.189.111.255
    inet6 fe80::e075:69ff:fe81:8efb  prefixlen 64  scopeid 0x20<link>
    ether e2:75:69:81:8e:fb  txqueuelen 1000  (Ethernet)
    RX packets 38152  bytes 155270488 (155.2 MB)
    RX errors 0  dropped 0  overruns 0  frame 0
    TX packets 19035  bytes 5002265 (5.0 MB)
    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

### Key Fields:
- **Interface Name (e.g., `eth0`)**: The name of the network interface.
- **`inet`**: The IPv4 address assigned to the interface.
- **`inet6`**: The IPv6 address assigned to the interface.
- **`ether`**: The MAC (hardware) address of the interface.
- **RX/TX Packets**: The number of packets received (`RX`) and transmitted (`TX`).
- **Errors/Collisions**: Metrics indicating potential network issues.

### Common Commands:
- View all network interfaces:
  ```bash
  ifconfig
  ```
- View a specific interface (e.g., `eth0`):
  ```bash
  ifconfig eth0
  ```
- Bring an interface up or down:
  ```bash
  sudo ifconfig eth0 up
  sudo ifconfig eth0 down
  ```

---
title: "Understanding Network Interfaces: Public, Private, and Loopback"
date: 2024-12-24
categories: [Networking, Linux]
tags: [Networking, Interfaces, Linux]
---

Network interfaces are essential for managing communication in a server. This post explains the roles of `eth0`, `eth1`, and `lo` network interfaces, what they do, and why they matter.

---

## 1. `eth0`: Public Network Interface

### Purpose
Handles communication with the public internet.

### Key Details
- **IP Address**: `inet 206.189.100.37`
  - A publicly routable IP address assigned to your droplet.
  - Enables the droplet to send and receive traffic over the internet.
- **MAC Address**: `ether e2:75:69:81:8e:fb`
  - Unique identifier for the network interface at the hardware level.
- **Traffic Statistics**:
  - **RX packets/bytes**: Received data traffic (e.g., downloads).
  - **TX packets/bytes**: Transmitted data traffic (e.g., uploads).

### Uses
- Connecting to the droplet from your local machine via SSH.
- Hosting websites or services accessible over the internet.
- Sending and receiving data to/from public endpoints.

---

## 2. `eth1`: Private Network Interface

### Purpose
Handles communication within the private network (e.g., between droplets in the same data center or VPC).

### Key Details
- **IP Address**: `inet 10.110.0.2`
  - A private IP address (non-routable on the public internet).
  - Used for internal communication within the private network.
- **MAC Address**: `ether 3a:f5:18:e5:8a:cd`
- **Traffic Statistics**:
  - Lower traffic compared to `eth0`, as it’s only used for private communication.

### Uses
- Secure communication between multiple droplets or servers.
- Reducing costs by avoiding public bandwidth usage (private network traffic is often free in cloud environments).
- Setting up distributed systems, private databases, or clusters where components communicate within the private network.

---

## 3. `lo`: Loopback Interface

### Purpose
Provides internal communication within the server itself.

### Key Details
- **IP Address**: `inet 127.0.0.1`
  - The loopback address (localhost) used for internal communication.
  - Not associated with any physical hardware.

### Uses
- Services or processes on the same server communicate through this interface.
- Debugging and testing.

---

## Why Are There Two Physical Interfaces?

### Public and Private Networking
- `eth0` is configured for external/public communication.
- `eth1` is for internal/private communication.
- Separating public and private traffic improves security and efficiency.

### Cost and Security Benefits
- Private network traffic (`eth1`) is typically free and more secure as it doesn’t traverse the public internet.
- Public network traffic (`eth0`) incurs bandwidth costs and requires secure protocols like SSH or HTTPS.

### Flexibility
By having both interfaces, you can configure your applications to handle public traffic (e.g., a web server) and private traffic (e.g., a database cluster) efficiently.

---

## Use Case Scenarios
- **`eth0`**:
  - Hosting a web application accessible to users on the internet.
  - Allowing SSH access from your local machine.
- **`eth1`**:
  - Communication with a private database or caching service.
  - Internal data replication between droplets in the same data center.
- **`lo`**:
  - Running services that only need to communicate within the server (e.g., localhost-based testing).

---

## How to Use This Setup

### Public Communication
Use the `eth0` IP address for external-facing services or to connect to the server from your machine.

### Private Networking
- Use the `eth1` IP address for internal services like a database or inter-droplet communication.
- Ensure private IP addresses are used only within the same private network or VPC.

### Local Testing
Use `127.0.0.1` for local services or applications running on the same server.

---





