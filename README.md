
# Antizapret VPN Docker Autosetup

This project provides an automated setup script for deploying an OpenVPN and WireGuard VPN server with antizapret functionality. The script handles the installation and configuration of all necessary components, making it easy to set up a secure and censorship-resistant VPN server.

## Features

- Automatic installation of OpenVPN and WireGuard
- Integration with the [antizapret-vpn-docker](https://github.com/xtrime-ru/antizapret-vpn-docker) project
- Regular updates of custom domain and IP lists
- Support for regex-based domain filtering
- Docker-based deployment for easy maintenance
- Optimized settings for performance and security
- User-friendly configuration through an `.env` file

## Requirements

To run this script, you need:

1. **A Linux server** (Ubuntu 20.04 or newer recommended).
2. **Root or sudo access** to the server.
3. **Installed Git and curl** (the script will install them if they are missing).
4. **Internet connection** to fetch updates and required packages.

## Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/your-repository.git
   cd your-repository
   ```

2. **Generate a bcrypt hash for your password**:
   - Follow the instructions in the [wg-easy guide](https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md) to generate a bcrypt hash for the WireGuard UI password.
   - You can use tools like [bcrypt-generator.com](https://bcrypt-generator.com/) or run the following command locally if you have Node.js installed:
     ```bash
     npx bcrypt your-secure-password
     ```

3. **Create an `.env` file** in the root directory:
   ```bash
   echo "password_hash=your_bcrypt_hash_here" > .env
   ```
   Replace `your_bcrypt_hash_here` with the generated bcrypt hash.

4. **Run the setup script**:
   ```bash
   ./install_script.sh
   ```

5. **Access your VPN**:
   - OpenVPN will be available on port `6841` (TCP/UDP).
   - WireGuard UI will be available on port `1481` (TCP).

## Customization

- **Custom Domain/IP Lists**: The script automatically downloads and applies custom domain and IP lists from:
  - Domains: [include-regex-custom.txt](http://omhvp.co/include-regex-custom.txt)
  - IPs: [include-ips-custom.txt](http://omhvp.co/include-ips-custom.txt)

- To modify these lists, update the files at the provided URLs or replace them locally in `/root/antizapret/config/`.

## Security

- The `.env` file is excluded from the repository to protect your credentials. Ensure this file is secure and accessible only to trusted users.
- Always use a secure password when generating the bcrypt hash for the WireGuard UI.

## Troubleshooting

If you encounter any issues:
1. Check the Docker containers' logs:
   ```bash
   docker logs <container_name>
   ```
2. Verify the `.env` file is correctly configured.
3. Restart the Docker containers:
   ```bash
   docker compose restart
   ```

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

---

**Enjoy a secure and censorship-free browsing experience with your own VPN!**
