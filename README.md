Cloud Services – Week 7: Infrastructure as Code with OpenTofu

Live page: http://128.214.255.177/ 
Repository: https://github.com/Mishomoon/cloud-services-week7

This repository contains my Week 7 project, where I rebuilt my cloud environment on CSC cPouta (OpenStack) using Infrastructure as Code with OpenTofu. Instead of clicking through the web interface, the whole environment is described in code, and OpenTofu creates, updates, destroys and rebuilds it.

The full documentation (Part A answers, experiments, security, problems, reflection, screenshots) is on the live page and in index.html.

What the code builds
#	Resource	Purpose
1	openstack_compute_keypair_v2	SSH key pair created from my public key
2	openstack_networking_secgroup_v2	Security group
3	openstack_networking_secgroup_rule_v2 (SSH)	SSH (22) only from my own IP (ssh_allowed_cidr)
4	openstack_networking_secgroup_rule_v2 (HTTP)	HTTP (80) from everywhere
5	openstack_networking_port_v2	Network port with the security group attached
6	openstack_compute_instance_v2.week7	Ubuntu VM, configured on first boot with cloud-init
7	openstack_networking_floatingip_v2.web	Floating IP (pool public) associated with the port

A data source (openstack_networking_network_v2) looks up the existing project network. Dependencies are implicit: the port depends on the security group, the VM on the port and key pair, and the floating IP on the port. OpenTofu uses these to decide creation order, and destroys in reverse.

Files
File	Purpose
provider.tf	OpenStack provider configuration (credentials come from the environment, never from the repo)
main.tf	The resources listed above
variables.tf	Input variables with descriptions, types and validation
outputs.tf	Outputs, including the public IP and page URL
terraform.tfvars.example	Example values with placeholders only; copy to terraform.tfvars and edit
cloud-init.yaml	First-boot setup: installs Apache and Git, clones this repo, publishes index.html, screenshots and the Week 1 PDF
index.html	The documentation web page served by the VM
screenshots/	Evidence of apply, outputs, web page and experiments
Cloud service (6).pdf	Week 1 document linked from the page
.gitignore	Keeps secrets and local state out of Git
.terraform.lock.hcl	Provider version lock
Variables
Variable	Description
instance_name	Name of the VM
image_name	Ubuntu image name
flavor_name	VM size
keypair_name	Name of the key pair created in OpenStack
network_name	Existing project network
ssh_public_key_path	Path to my public key file
ssh_allowed_cidr	Source address allowed to use SSH, e.g. 203.0.113.10/32. Validated with can(cidrhost(var.ssh_allowed_cidr, 0))
Outputs

The public (floating) IP address and the web page URL, plus basic VM information.

How to reproduce
Install OpenTofu and download your cPouta OpenStack RC file (keep it outside the repo). Source it so the provider can authenticate.
Clone the repository:
bash
   git clone https://github.com/Mishomoon/cloud-services-week7.git
   cd cloud-services-week7
Create your own settings file and fill in your values (your public key path and your own IP as /32):
bash
   cp terraform.tfvars.example terraform.tfvars
Run the workflow:
bash
   tofu init
   tofu validate
   tofu plan
   tofu apply
Open the URL from the outputs. Apache may need a minute after the VM starts while cloud-init finishes.
Clean up when finished: tofu destroy.

cloud-init clones this repository on the VM's first boot, so the repository must stay public and contain index.html, screenshots/ and the PDF. cloud-init only runs on first boot, so to publish a changed page, push it to GitHub and replace the VM:

bash
tofu apply -replace=openstack_compute_instance_v2.week7
Experiments

Each experiment was done with a prediction first, then the result and an explanation (details and screenshots on the live page).

Change. Changing user_data (cloud-init) forces the VM to be replaced, because it is only read on first boot. Changing only the security group description is an in-place update. Not every change means destroy and recreate.
Drift. I changed the security group description by hand in the cPouta interface to MANUAL DRIFT TEST. tofu plan compared the code and state with the real infrastructure, detected the difference and planned to change it back.
Destroy and rebuild. tofu destroy removed all seven managed resources in reverse dependency order (floating IP and VM before port and security group), and tofu apply created all seven again from the same code. Apache was reinstalled by cloud-init and the page came back. The private IP changed after the rebuild (new VM and port).
Security
SSH (22) is allowed only from my own IP; HTTP (80) is open to the Internet because the page must be public.
The key pair is created from my public key. The private key never enters the repository.
.gitignore excludes *.tfstate, *.tfstate.*, .terraform/, *.tfvars, *.tfvars.json, cloud.yaml, clouds.yaml, *.pem, *.key, id_rsa* and .env.
Not in the repository or screenshots: OpenStack RC file, passwords, application credentials, private keys, state files, or my real terraform.tfvars. Only terraform.tfvars.example with placeholders is committed.
Resources are destroyed when no longer needed.
Reflection 

Writing the environment as code took more effort than clicking through the web interface the first time. After that it is repeatable: the same code gives the same environment every time, plan shows exactly what will change, and drift from manual edits becomes visible. Manual setup is still fine for one-off experiments, but for anything I need to rebuild, review or share, Infrastructure as Code is the better fit. More detail is in the reflection section of the live page.

Evidence

The screenshots/ folder shows tofu init, validate, plan and apply, the outputs, the VM and floating IP, the working web page and the three experiments.
