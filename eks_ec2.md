If need to provision the cluster on EC2, then these steps needs to be performed, else the default is to provision on Fargate. Its an optional step, for the fargate the below steps can be skipped.

Edit eks/cluster.yaml. Comment section `fargateProfiles`. 

Change `managedNodeGroups.instanceType` to `t2.medium`.
Change `managedNodeGroups.desiredCapacity` to at least `2`

Install CSI drivers using the following instruction: 
https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/#Option_B.3A_Deploy_and_test_the_Amazon_EFS_CSI_driver
