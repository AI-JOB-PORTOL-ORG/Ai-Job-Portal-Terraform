resource "aws_security_group_rule" "rds_ingress_eks_nodes" {
  type                     = "ingress"
  description              = "PostgreSQL from EKS worker nodes"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.security_groups.database_security_group_id
  source_security_group_id = module.eks.node_security_group_id
}
