resource "aws_prometheus_scraper" "this" {
  source {
    eks {
      cluster_arn = var.eks_cluster_arn
      subnet_ids  = var.private_subnets_ids
    }
  }

  destination {
    amp {
      workspace_arn = aws_prometheus_workspace.this.arn
    }
  }

  scrape_configuration = var.scrap_configuration_content
}
