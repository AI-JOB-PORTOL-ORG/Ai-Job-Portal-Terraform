provider "aws" {
  region = local.aws_region
}

data "aws_eks_cluster" "hirevoice" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "hirevoice" {
  name = local.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.hirevoice.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.hirevoice.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.hirevoice.token
  }
}
