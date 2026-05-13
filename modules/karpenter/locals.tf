locals {
  events = {
    health_event      = "aws.health"
    rebalance_ann     = "aws.ec2"
    inst_state_change = "aws.ec2"
    spot_interruption = "aws.ec2"
  }

  event_types = {
    health_event      = ["AWS Health Event"]
    rebalance_ann     = ["EC2 Instance Rebalance Recommendation"]
    inst_state_change = ["EC2 Instance State-change Notification"]
    spot_interruption = ["EC2 Spot Instance Interruption Notice"]
  }
}
