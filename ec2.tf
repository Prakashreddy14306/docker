
resource "aws_instance" "hello" {
    ami    = "ami-09c813fb71547fc4f"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.my_sg.id]

    root_block_device {
    volume_size = 30  # Set root volume size to 30GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }

    tags = {
    Name = "Terraform-EC2"
  }
}

resource "aws_security_group" "my_sg" {
    name = "allow_all"
    description = " allow ssh to all"


    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Open SSH to all (modify for security)
    }

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Open SSH to all (modify for security)
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]  # Open SSH to all (modify for security)
    } 
    tags = {
    Name = "Terraform-EC2-sg"
  }

}


resource "null_resource" "docker" {
  # Changes to any instance of the instance requires re-provisioning
  triggers = {
    instance_id = aws_instance.hello.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = aws_instance.hello.public_ip
    type = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "docker-script.sh"
    destination = "/tmp/docker-script.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "sudo chmod +x /tmp/docker-script.sh",
      "sudo sh /tmp/docker-script.sh"
    ]
  }
}

output "public_ip" {
  value       = aws_instance.hello.public_ip
}
