#creating ec2 instance ec2.tf
resource "aws_instance""instance1"{
ami="ami-0f409bae3775dc8e5"
instance_type="t2.small"
key_name="vamsi"
vpc_security_group_ids=["${aws_security_group.demosg.id}"]
subnet_id=aws_subnet.public-subnet-1.id
associate_public_ip_address=true
user_data=file("data.sh")
tags={
Name="my public insatance1"
}
}
