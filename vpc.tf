
variable "subnets_cidr" {
	type = "list"
	default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "subnets_private" {
	type = "list"
	default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
	type = "list"
	default = ["us-west-2a", "us-west-2b"]
}
resource "aws_vpc" "terra_vpc" {
  cidr_block = "10.0.0.0/16"
  tags={
      Name = "Cloud_Vpc"

  }
}

resource "aws_internet_gateway" "iti_igw" {
    # to attach ig to vpc
    vpc_id= "${aws_vpc.terra_vpc.id}"

}
# subnet :puplic
resource "aws_subnet" "public_subnet" {
    vpc_id= "${aws_vpc.terra_vpc.id}"
    count= "${length(var.subnets_cidr)}"
    cidr_block = "${element(var.subnets_cidr,count.index)}"
    availability_zone = "${element(var.azs,count.index)}"

}
# subnets : private
resource "aws_subnet" "private_subnet" {
    vpc_id= "${aws_vpc.terra_vpc.id}"
    count= "${length(var.subnets_private)}"
    cidr_block = "${element(var.subnets_private,count.index)}"
    availability_zone = "${element(var.azs,count.index)}"
    
    
}

#public route table and associate it with gateway
resource "aws_route_table" "public_rt" {
    vpc_id="${aws_vpc.terra_vpc.id}"
    route{
        cidr_block="0.0.0.0/0"
        gateway_id="${aws_internet_gateway.iti_igw.id}"
    }

}

# route table private
resource "aws_route_table" "private_rt" {
    vpc_id = "${aws_vpc.terra_vpc.id}"

}

# route table association with private
resource "aws_route_table_association" "rtpv" {
    count= "${length(var.subnets_cidr)}"
    subnet_id="${element(aws_subnet.private_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.private_rt.id}"

}


# route table association with puplic subnet
# length to make loop on two subnet
# element to get one id
resource "aws_route_table_association" "rtass" {
    count= "${length(var.subnets_cidr)}"
    subnet_id="${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.public_rt.id}"

}
