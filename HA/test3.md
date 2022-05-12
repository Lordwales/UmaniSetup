## HIGH AVAILABILITY SOLUTION

  ### APPLICATION SERVER

To make our applicaton highly available, we need to add some more resources to the existing application resource. Talking about Load Balancer, Auto scaling, Bastion Host, and more, we will add these resources to the existing application resource.

At the moment we have the following resources:
- Application Server (a sungle node that runs but nginx as reverse proxy and also serves the Umami application)
- One Internet facing Load Balancer (LB) that connects to the application server in a private subnet
- RDS instance (a single node that stores the data for the application)
- Nat Gateway
- Internet Gateway
- Route Tables

The last three resources still remain the same; no change required.

1. We curently have one public subnet and two private subnets,we will need to add more. 3 public subnets and 3 private subnets. We wiil add Bastion Host to the public subnets for us to access the application nodes through SSH if need be. Thi Bastion hosts will be given a security group that allows SSH access to the application nodes.

N.B. Only the LB and Bastion Host will have access to the application nodes.

2. The Application nodes will be deployed in private subnets for security reasons. We have to add a security group to the application nodes that allows SSH access from the Bastion Host. There will be Three (3) private subnets in thrree (3) differnt AZs i.e Our 3 nodes will be deployed in three different AZs and auto scaling group will be implemented for these Node targets. 
<br>
This means we can scale up the nodes if some predefined metircs are met. That way, we can be guranteed that the application will be available. The load balancer will distribute the traffic to the nodes accordingly. Even if one of the nodes is down, a new one can be spinned up and the load balancer will distribute the traffic to the new node.

3. Since we are using RDS as the database, we will make use of AWS Multi-AZ feature. Amazon RDS automatically creates a primary database (DB) instance and synchronously replicates the data to an instance in a different AZ. When it detects a failure, Amazon RDS automatically fails over to a standby instance without manual intervention.