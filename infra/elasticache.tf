# ElastiCache Redis Cluster

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-${var.environment}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-redis-subnet-${var.environment}"
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "redis" {
  name   = "${var.project_name}-redis-params-${var.environment}"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  tags = {
    Name = "${var.project_name}-redis-params-${var.environment}"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis-${var.environment}"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  # Snapshot configuration
  snapshot_retention_limit = var.environment == "prod" ? 5 : 1
  snapshot_window          = "03:00-05:00"

  # Maintenance window
  maintenance_window = "sun:05:00-sun:07:00"

  # Logging
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name = "${var.project_name}-redis-${var.environment}"
  }
}

# CloudWatch Log Groups for Redis
resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/aws/elasticache/${var.project_name}-redis-${var.environment}/slow-log"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-redis-slow-log-${var.environment}"
  }
}

resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name              = "/aws/elasticache/${var.project_name}-redis-${var.environment}/engine-log"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-redis-engine-log-${var.environment}"
  }
}

# Alternative: ElastiCache Replication Group (for Redis Cluster mode or multi-AZ)
# Uncomment for production high-availability setup

# resource "aws_elasticache_replication_group" "redis_ha" {
#   replication_group_id       = "${var.project_name}-redis-ha-${var.environment}"
#   replication_group_description = "Redis replication group for ${var.project_name}"
#   
#   engine               = "redis"
#   engine_version       = "7.0"
#   node_type            = var.redis_node_type
#   port                 = 6379
#   parameter_group_name = aws_elasticache_parameter_group.redis.name
#   
#   subnet_group_name    = aws_elasticache_subnet_group.redis.name
#   security_group_ids   = [aws_security_group.redis.id]
#   
#   # Cluster configuration
#   num_cache_clusters         = 2
#   automatic_failover_enabled = true
#   multi_az_enabled          = true
#   
#   # At-rest encryption
#   at_rest_encryption_enabled = true
#   
#   # Transit encryption
#   transit_encryption_enabled = true
#   auth_token                = random_password.redis_auth_token.result
#   
#   # Snapshot configuration
#   snapshot_retention_limit = 5
#   snapshot_window         = "03:00-05:00"
#   
#   # Maintenance
#   maintenance_window = "sun:05:00-sun:07:00"
#   
#   tags = {
#     Name = "${var.project_name}-redis-ha-${var.environment}"
#   }
# }
#
# resource "random_password" "redis_auth_token" {
#   length  = 32
#   special = false
# }
