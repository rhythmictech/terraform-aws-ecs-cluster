#!/usr/bin/env fish
set old \
    aws_iam_role.ecs-instance-role \
    data.aws_iam_policy_document.ecs-instance-policy-document \
    aws_iam_role_policy.ecs-instance-policy \
    aws_iam_role_policy_attachment.ecs-instance-role-attachment \
    aws_iam_instance_profile.ecs-instance-profile \
    aws_security_group.ecs-alb-sg \
    aws_alb.ecs-load-balancer \
    data.aws_ami.ecs \
    aws_security_group.ecs_ec2_sg \
    aws_key_pair.smiller \
    aws_launch_configuration.ecs-launch-config \
    aws_autoscaling_group.ecs-asg \
    aws_ecs_cluster.ecs-cluster
set new \
    aws_iam_role.instance-role \
    data.aws_iam_policy_document.instance-assume-role-policy-document \
    aws_iam_role_policy.instance-policy \
    aws_iam_role_policy_attachment.instance-role-attachment \
    aws_iam_instance_profile.instance-profile \
    aws_security_group.alb-sg \
    aws_lb.cluster-alb \
    data.aws_ami.ecs \
    aws_security_group.ec2_sg \
    aws_key_pair.default \
    aws_launch_configuration.cluster-lc \
    aws_autoscaling_group.cluster-asg \
    aws_ecs_cluster.default

if test (count $old) = (count $new)
    set i 1
    for val in $old
        terraform state mv $old[$i] module.ecs-cluster.$old[$i]
        # echo $old[$i] module.ecs-cluster.$new[$i]
        set i (math --scale=0 $i + 1)
    end
else
    exit 1
end
