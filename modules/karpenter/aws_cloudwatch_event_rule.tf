resource "aws_cloudwatch_event_rule" "karpenter_rules" {
  for_each = var.enable_interruption_handling ? local.events : {}

  name        = "Karpenter-${each.key}-${var.cluster_name}"
  description = "Karpenter interruption rule for ${each.key}"

  event_pattern = jsonencode({
    source      = [each.value]
    detail-type = local.event_types[each.key]
  })
}

resource "aws_cloudwatch_event_target" "karpenter_targets" {
  for_each = var.enable_interruption_handling ? local.events : {}

  rule      = aws_cloudwatch_event_rule.karpenter_rules[each.key].name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.karpenter[0].arn
}
