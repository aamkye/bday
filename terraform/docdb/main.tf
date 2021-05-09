resource "aws_docdb_subnet_group" "main" {
  subnet_ids = var.private_subnets.*.id

  tags = {
    Name = "docbd_subnet_group_main"
  }
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "main-cluster"
  engine                  = "docdb"
  master_username         = var.dbusername
  master_password         = var.dbpassword
  backup_retention_period = 1
  skip_final_snapshot     = true
  availability_zones      = var.availability_zones
  db_subnet_group_name    = aws_docdb_subnet_group.main.name
  vpc_security_group_ids  = [var.mongo_sg.id]

  tags = {
    Name = "docbd_main"
  }
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 3
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = "db.t3.medium"

  tags = {
    Name = "docbd_main_instance_${format("%03d", count.index + 1)}"
  }
}
