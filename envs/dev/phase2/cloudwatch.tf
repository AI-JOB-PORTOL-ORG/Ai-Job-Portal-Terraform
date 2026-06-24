variable "alert_email" {
  description = "Optional email address subscribed to HireVoice CloudWatch alarms. Leave empty to create the SNS topic without an email subscription."
  type        = string
  default     = ""
}

locals {
  cloudwatch_dashboard_name = "HireVoice-Overview"
  hirevoice_alb_name        = "k8s-hirevoic-hirevoic-36e944838f"
  rds_instance_identifier   = "hirevoice-dev-postgres"
  node_group_name           = "hirevoice-dev-eks-managed-ng"
  node_group_asg_name       = "eks-hirevoice-dev-eks-managed-ng-62cf7b08-eb35-d55b-3490-a55c26b704f7"
  alb_dimension             = replace(data.aws_lb.hirevoice.arn, "arn:aws:elasticloadbalancing:${local.aws_region}:${local.account_id}:loadbalancer/", "")
  cloudwatch_alarm_actions  = [aws_sns_topic.hirevoice_alerts.arn]
  rds_low_storage_threshold = 2147483648
  rds_high_connection_limit = 80
  alb_response_time_seconds = 2
  alb_5xx_error_threshold   = 5
}

data "aws_lb" "hirevoice" {
  name = local.hirevoice_alb_name
}

resource "aws_sns_topic" "hirevoice_alerts" {
  name = "hirevoice-alerts"

  tags = merge(local.common_tags, {
    Name = "hirevoice-alerts"
  })
}

resource "aws_sns_topic_subscription" "hirevoice_alert_email" {
  count     = var.alert_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.hirevoice_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_dashboard" "hirevoice_overview" {
  dashboard_name = local.cloudwatch_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# HireVoice Overview\nAWS-managed CloudWatch metrics only. No agents, Fluent Bit, Container Insights, workload manifests, or application code changes are required."
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          title   = "ALB Traffic and Latency"
          region  = local.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_dimension, { stat = "Sum", label = "Request Count" }],
            [".", "TargetResponseTime", ".", ".", { stat = "Average", label = "Target Response Time" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          title   = "ALB 5XX Errors"
          region  = local.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", local.alb_dimension, { stat = "Sum", label = "ELB 5XX" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { stat = "Sum", label = "Target 5XX" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6
        properties = {
          title   = "RDS Utilization"
          region  = local.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", local.rds_instance_identifier, { stat = "Average", label = "CPU %" }],
            [".", "DatabaseConnections", ".", ".", { stat = "Average", label = "Connections" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6
        properties = {
          title   = "RDS Capacity"
          region  = local.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", local.rds_instance_identifier, { stat = "Average", label = "Free Storage Bytes" }],
            [".", "FreeableMemory", ".", ".", { stat = "Average", label = "Freeable Memory Bytes" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 12
        height = 6
        properties = {
          title   = "EKS Node CPU"
          region  = local.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", local.node_group_asg_name, { stat = "Average", label = "Node CPU %" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 14
        width  = 12
        height = 6
        properties = {
          title   = "EKS Node Group Capacity"
          region  = local.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", local.node_group_asg_name, { stat = "Average", label = "Desired Capacity" }],
            [".", "GroupInServiceInstances", ".", ".", { stat = "Average", label = "In-Service Nodes" }],
            [".", "GroupTotalInstances", ".", ".", { stat = "Average", label = "Total Nodes" }]
          ]
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 20
        width  = 24
        height = 2
        properties = {
          markdown = "EKS node memory is not emitted by AWS-managed metrics without CloudWatch Agent, Fluent Bit, or Container Insights. Those are intentionally not enabled in this phase."
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_elb_5xx_high" {
  alarm_name          = "${local.name_prefix}-alb-elb-5xx-high"
  alarm_description   = "HireVoice ALB generated high ELB 5XX errors."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = local.alb_5xx_error_threshold
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.cloudwatch_alarm_actions
  ok_actions          = local.cloudwatch_alarm_actions

  dimensions = {
    LoadBalancer = local.alb_dimension
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx_high" {
  alarm_name          = "${local.name_prefix}-alb-target-5xx-high"
  alarm_description   = "HireVoice ALB targets returned high 5XX errors."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = local.alb_5xx_error_threshold
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.cloudwatch_alarm_actions
  ok_actions          = local.cloudwatch_alarm_actions

  dimensions = {
    LoadBalancer = local.alb_dimension
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time_high" {
  alarm_name          = "${local.name_prefix}-alb-response-time-high"
  alarm_description   = "HireVoice ALB target response time is high."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  threshold           = local.alb_response_time_seconds
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.cloudwatch_alarm_actions
  ok_actions          = local.cloudwatch_alarm_actions

  dimensions = {
    LoadBalancer = local.alb_dimension
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.name_prefix}-rds-cpu-high"
  alarm_description   = "HireVoice RDS CPU utilization is above 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  threshold           = 80
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.cloudwatch_alarm_actions
  ok_actions          = local.cloudwatch_alarm_actions

  dimensions = {
    DBInstanceIdentifier = local.rds_instance_identifier
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_low" {
  alarm_name          = "${local.name_prefix}-rds-free-storage-low"
  alarm_description   = "HireVoice RDS free storage is below 2 GiB."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = local.rds_low_storage_threshold
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.cloudwatch_alarm_actions
  ok_actions          = local.cloudwatch_alarm_actions

  dimensions = {
    DBInstanceIdentifier = local.rds_instance_identifier
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${local.name_prefix}-rds-connections-high"
  alarm_description   = "HireVoice RDS database connection count is high."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  threshold           = local.rds_high_connection_limit
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.cloudwatch_alarm_actions
  ok_actions          = local.cloudwatch_alarm_actions

  dimensions = {
    DBInstanceIdentifier = local.rds_instance_identifier
  }

  tags = local.common_tags
}
