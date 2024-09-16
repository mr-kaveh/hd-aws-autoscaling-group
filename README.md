# hd-aws-autoscaling-group
## Set Up an Auto Scaling Group

The goal is to create a web server that can scale up and down to meet website traffic demands. For example, if your website is getting a lot of traffic then it adds more EC2 instances to deal with the increased load, and when the traffic goes down, it reduces the number of EC2 instances to save on costs.

![image](https://github.com/user-attachments/assets/64350253-37c7-4d44-8bb2-ebf09b66727a)

## VPC
 It involves creating 3 public subnets and 3 private subnets. Here, is where all the resources are created.

## EC2
-   **Security Groups**: The backend security group now only allows inbound traffic from the frontend security group.
-   **Frontend Instances**: Creates 3 frontend EC2 instances in public subnets.
-   **Backend Instances**: Creates 3 backend EC2 instances in private subnets, running Apache web server that prints the instance ID.
-   **Load Balancer**: Sets up an Application Load Balancer with a target group and listener.
-   **Target Group Attachment**: Attaches frontend instances to the load balancer’s target group.

## Autoscaling Group
-   **Launch Template**: Defines the configuration for the EC2 instances, including the AMI, instance type, security groups, and user data.
-   **Auto Scaling Group**: Manages the desired number of instances, scaling up or down based on demand. It uses the launch template and is connected to the ALB’s target group.
-   **Security Groups**: Defines security groups for frontend and backend instances.
-   **Load Balancer**: Sets up an Application Load Balancer with a target group and listener.
-   **Target Group Attachment**: Attaches frontend instances to the load balancer’s target group.


To trigger scaling we use Target Tracking. This is where you set a policy that you always want the average CPU utilisation to be something like 30%,this means that the instances get added or taken away automatically so that the average is always 30% no matter how much or how little traffic comes into the service.
