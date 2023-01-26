## Troubleshooting

1. The created EKS resources are not visible on the AWS Console, one of the reason is that the user who created the cluster is differnt from the one whoe logged in on the console.

    - Add in cluster file
    
        iamIdentityMappings:
        - arn: arn:aws:iam::666638856807:role/OrganizationAccountAccessRole
            groups:
            - system:masters
            username: admin
            noDuplicateARNs: true
            
            eksctl get iamidentitymapping -f helm/cluster.yaml --profile hub-cdp-profile

    - Run following command
        eksctl create iamidentitymapping -f helm/cluster.yaml

    - Check the identity
        eksctl get iamidentitymapping -f helm/cluster.yaml --profile hub-cdp-profile\