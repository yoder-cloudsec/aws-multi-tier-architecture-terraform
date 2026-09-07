resource "aws_db_subnet_group" "main" {
  name       = "cloud-eng-db-subnet-group"
  subnet_ids = [aws_subnet.private-1a.id, aws_subnet.private-1b.id]

  tags = {
    Name = "cloud-eng-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier              = "cloud-eng-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "mydb"
  username                = "admin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  publicly_accessible     = false
  multi_az                = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = {
    Name = "cloud-eng-db"
  }
}