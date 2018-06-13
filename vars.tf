variable "azs_count"{
  default ="2"
}

variable "tagname_subnet" {
  default = "testSubnet"
}

variable "publicsubnets" {
	type = "list"
	default = ["subnet-0c1284c38971c3628","subnet-04d38421520bd8e59"]
}

variable "vpc_id" {
	default = "vpc-0c604326e98a8b5c7"
	
}
