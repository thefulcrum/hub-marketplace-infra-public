# Welcome to the repository to setup N3Hub CDP

This is a configuration repository that is going to help you set up the environment to run the CDP. There are two main parts of this repo. 

The first one is to provide the resources using terraform and the second one is to use Kubernetes to run the containers.

The files related to the terraform are under the terraform directory, and the ones related to Kubernetes are in the eks directory, while the config folder is having the configuration files templates.

## Note
Please contact sales@n3hub.com to complete your onboarding and set up of our Customer Data Platform.

## Resources by terraform

Following is the list of the resources that are going to be provisioned by terraform.

- AWS VPC, and public-private subnets.
- AWS RDS Databases, there are two separate Databases.
- AWS Elasticache for the Redis.
- AWS Secrets to store the passwords and encryption key as well as JWT secret, all of these are required by our application.
- AWS S3 bucket for the CDP to upload the files from the UI.
- AWS IAM role for our resources, so it can upload the data in the S3 bucket.
- AWS EFS, a file system which will be shared across our pods.


## Library Requirements

- Terraform [cli](https://developer.hashicorp.com/terraform/downloads) Version: 1.3.7
- AWS [cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with access to your aws account
- [helm](https://helm.sh/) cli 
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [eksctl](https://eksctl.io/)

## Configurations

Once the above libraries are installed, then the AWS CLI needs to be configured with appropriate access level, so the resources can be provisioned. Following guide can be followed to set up the cli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html


## Steps to follow

Once the above-required libraries are installed, the following instructions are to be executed.

1. Run the terraform instruction. 

    For terraform to work it needs AWS access and secret key with right permission so the resources can be created. By default, resources gets created prefixed with "app_name" and "env" mentioned in the `terraform/terraform.tfvars` file. They can be changed before running the below commands.

    ```
    cd terraform
    terraform init
    terraform plan
    terraform apply
    cd ..
    ```

    As a result, three files appear in `eks` folder: 

    - `rawconfig.json` - config file for all CDP modules. 
    - `alembic.ini` - setting for alembic module, uses for DB migrations. 
    - `cluster.yaml` - an EKS-cluster file.
    
    These files contain sensitive information such as passwords and secret tokens. Please keep them in a safe place.

2. EKS Cluster deployment: 

    This step is about deployment the EKS cluster.

    - **Optional step**: If you like to use Ec2, please refer to "eks_ec2.md"
        
    Create a new cluster and load the secrets

    ```
    eksctl create cluster -f ./eks/cluster.yaml

    kubectl create secret generic rawconfig --from-file=./eks/rawconfig.json
    kubectl create secret generic alembic --from-file=./eks/alembic.ini
    ```

3. Install ingress controller

    To make the CDP services reachable from the internet following ingress controller needs to be created.

    ```
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/deploy.yaml
    ```
    
    Wait 5-10 minutes while Network Load Balancer provisioned. Get URL of NLB:
    
    ```
    kubectl describe service ingress-nginx-controller -n ingress-nginx | grep "LoadBalancer Ingress"
    ```
    

4. Install EFS resources

   EFS (AWS Elastic File System) is required by the CDP, this is going to make the mounting of the EFS.

   ```
   kubectl apply -f ./eks/efs.yaml
   ```

5. Download the images

    This step will only work if you have subscribed to the CDP from in the AWS marketplace.

    ```
    aws ecr get-login-password \
    --region us-east-1 | docker login \
    --username AWS \
    --password-stdin 709825985650.dkr.ecr.us-east-1.amazonaws.com
    
    CONTAINER_IMAGES="709825985650.dkr.ecr.us-east-1.amazonaws.com/n3-hub/cdp-ui:0.3,709825985650.dkr.ecr.us-east-1.amazonaws.com/n3-hub/cdp-api:0.3"    

    for i in $(echo $CONTAINER_IMAGES | sed "s/,/ /g"); do docker pull $i; done
    ```

6. Push the images on the AWS ECR

    Once the above images downloaded, they need to be loaded to the AWS ECR, so Helm chart can provision them.

    For the below commands to work, following variables need to be setup, and they need to have the same values under which the resources are getting provisioned.

    ```
    RELEASE_NUMBER=0.3
    AWS_ACCOUNT_ID=YOUR_ACCOUNT_ID
    AWS_REGION=ap-southeast-2

    echo "Create ECR repos"
    aws ecr create-repository --repository-name n3-hub/cdp-api
    aws ecr create-repository --repository-name n3-hub/cdp-ui

    echo "Tag the images"
    docker tag 709825985650.dkr.ecr.us-east-1.amazonaws.com/n3-hub/cdp-ui:$RELEASE_NUMBER   $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/n3-hub/cdp-ui:$RELEASE_NUMBER
    docker tag 709825985650.dkr.ecr.us-east-1.amazonaws.com/n3-hub/cdp-api:$RELEASE_NUMBER $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/n3-hub/cdp-api:$RELEASE_NUMBER
    
    echo "Get password"

    aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

    echo "Push the images to AWS ECR"
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/n3-hub/cdp-ui:$RELEASE_NUMBER
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/n3-hub/cdp-api:$RELEASE_NUMBER
    ```

7. Install the application
 
    This is going to deploy the CDP application to the cluster.
    
   ```
    helm install api ./eks/hub-api --set image.repository=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/n3-hub/cdp-api --set image.tag=$RELEASE_NUMBER
    helm install ui ./eks/fulcrum-hub-admin --set image.repository=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/n3-hub/cdp-ui --set image.tag=$RELEASE_NUMBER
    ```
    
    Following command can be used to get the admin user password.
    ```
    kubectl exec -i -t --namespace default $(kubectl get pods --namespace default -l app.kubernetes.io/name=hub-api -o jsonpath='{.items[0].metadata.name}') sh 
    python /usr/local/bin/passgen
    ```
    
    Note:
    Wait until all pods are up and running by using the command `kubectl get pods` and then please use the given command to get a new admin password. You can use the same command anytime if you need to reset your admin password. 
    
    For the pods status command `kubectl get pods` please check the columns 'ready' and 'status'. Values should be '1/1' and 'Running' respectively to consider the pod successfully started.

    This output of the pods command is showing that all pods are in running state, this can take around 5 to 10 minutes for all pods to enter the Running state.

    ```
    NAME                                            READY   STATUS    RESTARTS   AGE
    api-hub-api-66bc5c5974-9f9xv                    1/1     Running   0          7m18s
    ui-6669978659-rv554                             1/1     Running   0          6m39s
    ```

8. Custom domain

    This section required a basic knowledge of AWS Route 53 (DNS) and registered domain, ex: *example.com*
        
    1. In *Route 53* add a CNAME record pointing to your ingress url (see previous section).
    Wait until dns record propagate through. It may take up to 24 hours. Check DNS record:
    
    ```
    host -a hub.example.com
   
    Trying "hub.example.com"
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 65167
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 4, ADDITIONAL: 0
    
    ;; QUESTION SECTION:
    ;hub.example.com.	IN	ANY
    
    ;; ANSWER SECTION:
    hub.example.com. 60	IN	CNAME	a204c3c336f2f432e82c80d8ab2bded0-9ae37bacd53d8406.elb.ap-southeast-2.amazonaws.com.
    
    ;; AUTHORITY SECTION:
    example.com.	    80944	IN	NS	ns-616.awsdns-13.net.
    example.com.   	    80944	IN	NS	ns-1080.awsdns-07.org.
    example.com.   	    80944	IN	NS	ns-1681.awsdns-18.co.uk.
    example.com.    	80944	IN	NS	ns-32.awsdns-04.com.
    
    Received 272 bytes from 127.0.0.53#53 in 43 ms
    ```
    2. Check if CDP console works using your subdomain: http://hub.example.com  
    
9. SSL Termination
   
   1. Before install ingress controller with TLS termination you need to delete existed ingress controller:
  
   ```shell
   kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/deploy.yaml
   ```
   
   2. Please follow the instructions for installing ingress-nginx with TLS termination on the [official website](https://kubernetes.github.io/ingress-nginx/deploy/#tls-termination-in-aws-load-balancer-nlb).
   For these instructions your need EKS CIDR block: `proxy-real-ip-cidr: "10.0.0.0/16"` and ARN of your certificate which you can find in AWS console under *Certificate Manager*
   
   3. Check http**s**://hub.example.com. Check http://hub.example.com link which should redirect to http**s**. 

## Clean up

    These commands will allow you to delete all the resources that have been provisioned using the above commands.

    - Delete Network Load Balancer:
    
    ```shell
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/deploy.yaml
    ```
    If installed NLB with SSL termination use `deploy.yaml` file to delete all resources

    ```
    kubectl delete -f deploy.yaml
    ```

   - Uninstall CDP:
   
   ```shell
   helm uninstall ui
   helm uninstall api
   ```
   
   - Delete EFS resources
   
   ```shell
   kubectl delete -f ./eks/efs.yaml   
   ```
   
   - Delete EKS cluster
   
   ```shell
   eksctl delete cluster -f ./eks/cluster.yaml
   ```
   
   - Delete all provisioned resources
   
   ```shell
   cd terraform
   terraform destroy
   ```

## Useful links
   1. [Ingress Nginx](https://kubernetes.github.io/ingress-nginx/deploy/#aws)
   2. [Advanced configuration of nginx ingress controller](https://docs.nginx.com/nginx-ingress-controller/configuration/ingress-resources/advanced-configuration-with-annotations/)
   3. [AWS EFS](https://aws.amazon.com/premiumsupport/knowledge-center/eks-persistent-storage/)