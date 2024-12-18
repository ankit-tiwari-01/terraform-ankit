# Launch Backend EC2 Instance
resource "aws_instance" "back" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  # Uncomment and configure if needed
  # subnet_id              = aws_subnet.pub2.id
  # vpc_security_group_ids = [aws_security_group.backend_server_sg.id]

  # Check that backend.sh exists and use it for user data initialization
  user_data = file("${path.module}/backend.sh") # Correct use of file() function

  tags = {
    Name = "backend-server" # Correct capitalization
  }
}


# Null Resource for Remote-Exec Provisioning
resource "null_resource" "back" {
  depends_on = [aws_instance.back]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"                          # Correct username for Ubuntu AMI
      private_key = file("~/.ssh/id_ed25519")         # Correct path to private key
      host        = aws_instance.back.public_ip       # Use the public IP of the EC2 instance
    }

    # Inline commands to configure the backend server
    inline = [
      # Update system packages
      "sudo apt-get update -y",                       # Use apt-get for consistency

      # Install Apache
      "sudo apt-get install -y apache2",              # Install Apache
      "sudo systemctl start apache2",                 # Start Apache
      "sudo systemctl enable apache2",                # Enable Apache to start on boot

      # Install Node.js (v18)
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -", # Node.js setup
      "sudo apt-get install -y nodejs",               # Install Node.js

      # Install Corepack and PM2
      "sudo npm install -g corepack",                 # Install Corepack globally
      "corepack enable",                              # Enable Corepack
      "corepack prepare yarn@stable --activate",      # Prepare and activate Yarn
      "sudo npm install -g pm2",                      # Install PM2 globally

      # Ensure PM2 runs Apache or Node.js apps on startup
      "pm2 startup systemd",                          # Generate startup script
      "sudo systemctl restart apache2"                # Restart Apache to ensure it’s running
    ]
  }
}