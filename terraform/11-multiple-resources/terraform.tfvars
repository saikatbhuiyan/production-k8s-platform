subnet_config = {
    default = {
        cidr_block = "10.0.0.0/24"
    }

    subnet_1 = {
        cidr_block = "10.0.1.0/24"
    }
}

ec2_instance_config = {
    ubuntu_instance = {
        instance_type = "t2.micro",
        ami = "ubuntu"
    }

    nginx_instance = {
        instance_type = "t2.micro",
        ami = "nginx"
    }
}