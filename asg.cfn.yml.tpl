Description: "${description}"
Resources:
  ASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier: ["${subnets}"]
      LaunchConfigurationName: "${launchConfig}"
      MinSize: "${minSize}"
      MaxSize: "${maxSize}"
      DesiredCapacity: "${desiredCapacity}"
      HealthCheckType: "${healthCheck}"

    CreationPolicy:
      AutoScalingCreationPolicy:
        MinSuccessfulInstancesPercent: 80
      ResourceSignal:
        Count: %{ if desiredCapacity > 0 }1%{ else }0%{ endif }
        Timeout: PT30M    # Set long creation timeout so you can ssh in to troubleshoot if needed
    UpdatePolicy:
    # Ignore differences in group size properties caused by scheduled actions
      AutoScalingScheduledAction:
        IgnoreUnmodifiedGroupSizeProperties: true
      AutoScalingRollingUpdate:
        MaxBatchSize: "${maxBatch}"
        MinInstancesInService: "${minInService}"
        MinSuccessfulInstancesPercent: 80
        PauseTime: PT5M
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
        WaitOnResourceSignals: %{ if desiredCapacity > 0 }true%{ else }false%{ endif }
    DeletionPolicy: Delete
