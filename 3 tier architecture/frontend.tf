resource "aws_instance" "front" {
  ami           = var.ami # Use variable without quotes
  instance_type = var.instance_type
  key_name      = var.key_name

  # Uncomment and replace with appropriate values if needed
  # subnet_id             = aws_subnet.pub1.id
  # vpc_security_group_ids = [aws_security_group.frontend_server_sg.id]

  # Optional: Use this to specify startup scripts for the instance
  # user_data = templatefile("./frontend.sh", {})

  tags = {
    Name = "frontend-server"
  }
}

resource "null_resource" "front" {
  depends_on = [aws_instance.front]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"                           # Use "ubuntu" for Ubuntu instances
      private_key = file("~/.ssh/id_ed25519")         # Path to your private key
      host        = aws_instance.front.public_ip      # Reference the public IP of the instance
    }

    inline = [
      "sudo apt update -y",                           # Update the package index
      "sudo apt install apache2 -y",                 # Install Apache
      "sudo systemctl start apache2",                # Start Apache
      "sudo systemctl enable apache2",               # Enable Apache to start on boot
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -", # Set up Node.js repository
      "sudo apt-get install -y nodejs",              # Install Node.js
      "sudo apt update -y",                          # Update again after installing Node.js
      "sudo npm install -g corepack",                # Install Corepack globally
      "corepack enable",                             # Enable Corepack
      "corepack prepare yarn@stable --activate",     # Prepare and activate Yarn
      "sudo npm install -g pm2"                      # Install PM2 globally
    ]
  }
}