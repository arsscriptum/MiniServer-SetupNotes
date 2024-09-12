# Firewalls and Docker Containers

It is possible to apply firewall rules that target a specific Docker container, including one running with an integrated VPN such as `docker-transmission-openvpn`. This can be achieved by creating firewall rules that apply to the container's network interface or specific IP address. There are a few approaches to achieve this:

### Approach 1: Using Docker's `--network` to Create a Dedicated Network
You can assign a Docker container to a dedicated network and apply firewall rules on that network.

#### Steps:

1. **Create a Docker Network**:
   Create a custom network for the container. For example:
   ```bash
   docker network create vpn_net
   ```

2. **Run the Container on the Custom Network**:
   Start the `docker-transmission-openvpn` container using this network:
   ```bash
   docker run --network=vpn_net --name transmission-vpn --cap-add=NET_ADMIN --device=/dev/net/tun --env-file=transmission.env haugene/transmission-openvpn
   ```

3. **Find the Network Interface**:
   The Docker network you created (`vpn_net`) will have its own network interface on the host. You can list the network interfaces by running:
   ```bash
   ip addr show
   ```

   The Docker network interface will typically have a name like `br-<ID>`, and this is the interface associated with your custom Docker network.

4. **Apply UFW Rules to the Interface**:
   Once you have the correct network interface, you can use UFW to block or allow traffic on that interface. For example:
   ```bash
   sudo ufw allow in on br-<ID>  # Allow inbound traffic on the container network
   sudo ufw deny out on br-<ID>  # Deny outbound traffic on the container network
   ```

### Approach 2: Using `iptables` for Container-Specific Rules
You can also directly use `iptables` to create firewall rules for a specific Docker container based on its internal IP address or network interface.

#### Steps:

1. **Get the Container's IP Address**:
   Find the IP address of the running container:
   ```bash
   docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' transmission-vpn
   ```

2. **Apply iptables Rules**:
   You can then apply `iptables` rules for that specific container's IP. For example:

   - To block all outgoing traffic from the container:
     ```bash
     sudo iptables -A OUTPUT -s <container-ip> -j DROP
     ```

   - To allow incoming traffic on a specific port:
     ```bash
     sudo iptables -A INPUT -s <container-ip> -p tcp --dport 9091 -j ACCEPT
     ```

3. **Persist the iptables Rules**:
   To ensure the iptables rules persist after a reboot, you can save them using:
   ```bash
   sudo iptables-save > /etc/iptables/rules.v4
   ```

### Approach 3: Using Docker Compose with a Network and Firewall
If you're using Docker Compose, you can define a dedicated network in your `docker-compose.yml` file and then apply rules to that network.

```yaml
version: "3"
services:
  transmission-vpn:
    image: haugene/transmission-openvpn
    networks:
      - vpn_net
    environment:
      - OPENVPN_PROVIDER=...
      - TRANSMISSION_...

networks:
  vpn_net:
    driver: bridge
```

Then, follow the steps mentioned in **Approach 1** to apply firewall rules to the `vpn_net` network.

### Conclusion:
Yes, it's possible to apply firewall rules specifically to a Docker container running with a VPN. You can do this either by targeting the container's network interface, using custom Docker networks, or by directly applying rules using `iptables` or `ufw`. These methods allow you to enforce network isolation and traffic control on a per-container basis.