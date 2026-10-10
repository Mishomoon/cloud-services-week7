# Cloud Services – Week 7: Infrastructure as Code with OpenTofu

**Cloud platform:** CSC cPouta (OpenStack)  
**Tool:** OpenTofu  
**Live webpage:** [http://128.214.255.177/](http://128.214.255.177/)  
**GitHub repository:** [https://github.com/Mishomoon/cloud-services-week7](https://github.com/Mishomoon/cloud-services-week7)

## 1. Project overview

In Week 1, I created a Linux virtual machine manually in cPouta and configured the web server myself. In Week 7, I used **Infrastructure as Code (IaC)** to describe and manage the infrastructure with OpenTofu.

The project creates a virtual machine, a key pair, a network port, a security group with rules, and a floating IP. The `cloud-init.yaml` configuration installs Apache and publishes the webpage when the VM first boots. This makes the setup repeatable without configuring the web server manually.

## 2. Main goals

- Describe cloud infrastructure in code instead of creating it through the dashboard.
- Use variables, validation, and outputs to make the configuration reusable.
- Restrict network access with a security group: HTTP from everywhere and SSH only from my own public IP.
- Use cloud-init to configure Apache and copy the webpage from this public GitHub repository.
- Practise planning, applying, detecting configuration drift, and destroying and recreating resources.

## 3. Resources created

| # | Resource | Purpose |
|---|---|---|
| 1 | `openstack_compute_keypair_v2` | Creates a key pair from my public SSH key |
| 2 | `openstack_networking_secgroup_v2` | Defines the security group |
| 3 | `openstack_networking_secgroup_rule_v2` (SSH) | Allows SSH (TCP 22) only from `ssh_allowed_cidr` |
| 4 | `openstack_networking_secgroup_rule_v2` (HTTP) | Allows HTTP (TCP 80) from `0.0.0.0/0` |
| 5 | `openstack_networking_port_v2` | Creates the network port with the security group attached |
| 6 | `openstack_compute_instance_v2.week7` | Creates the Ubuntu VM and configures it using cloud-init |
| 7 | `openstack_networking_floatingip_v2.web` | Creates a floating IP and associates it with the network port |

The existing project network is looked up with a data source. Resource dependencies determine the creation and destruction order. For example, the port depends on the security group, the VM depends on the port and key pair, and the floating IP depends on the port.

## 4. Project files

| File or folder | Purpose |
|---|---|
| `main.tf` | Defines the OpenStack resources |
| `variables.tf` | Defines input variables, descriptions, types, and validation |
| `outputs.tf` | Displays outputs such as the public IP, webpage URL, instance name, and private IP |
| `provider.tf` | Configures the OpenStack provider |
| `.terraform.lock.hcl` | Records the selected provider version |
| `cloud-init.yaml` | Installs Apache and Git, clones the repository, copies the webpage and supporting files, and starts Apache |
| `terraform.tfvars.example` | Provides example variable values |
| `.gitignore` | Excludes state files, private configuration, keys, and other files that should not be committed |
| `index.html` | Contains the documentation webpage served by Apache |
| `screenshots/` | Contains evidence from OpenTofu commands, cPouta, and the experiments |
| `Cloud service (6).pdf` | Week 1 document linked from the webpage |

## 5. Requirements and setup

Before running the project, you need:

- OpenTofu installed.
- Access to your CSC cPouta project.
- OpenStack authentication configured using the cPouta RC file or application credentials.
- A public SSH key available locally.
- The correct image, flavor, network, and key-pair settings in `terraform.tfvars`.

Keep application-credential secrets, private SSH keys, `terraform.tfvars`, and OpenTofu state files out of the public repository.

## 6. Run the project

First, open PowerShell in the project folder and create your local variable file from the example:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to match your cPouta project. Make sure your OpenStack authentication is configured before continuing.

Run the following commands:

```powershell
tofu init
tofu validate
tofu plan
tofu apply
tofu output
```

Review the plan before approving the changes. OpenTofu will ask for confirmation before applying the planned changes.

To remove the infrastructure managed by this configuration, run:

```powershell
tofu destroy
```

**Warning:** `tofu destroy` deletes the infrastructure managed by this configuration. Review the plan carefully before confirming.

## 7. Networking and security

- **HTTP (TCP 80):** open to `0.0.0.0/0` so visitors can access the webpage.
- **SSH (TCP 22):** restricted to my current public IP using a `/32` CIDR.
- **SSH key pair:** OpenTofu creates the cloud key pair from the configured public key. The private key is not stored in the repository.
- **Secrets:** `.gitignore` excludes files such as `*.tfstate`, `*.tfvars`, `.terraform/`, `clouds.yaml`, `*.pem`, `*.key`, `id_rsa*`, and `.env`.

My public IP can change. If SSH access stops working, I must check my current public IP and update `ssh_allowed_cidr` before applying the configuration. SSH should not be opened to everyone.

## 8. How cloud-init updates the webpage

When the VM first boots, `cloud-init.yaml` installs Apache and Git, clones this public GitHub repository, and copies `index.html` and the supporting files into Apache's web directory.

**Pushing changes to GitHub does not automatically update the webpage on an existing VM.** The cloud-init commands run during the initial boot, so the VM continues serving its existing local copy.

To publish an updated webpage, first commit and push the changes to GitHub:

```powershell
git add README.md
git commit -m "Update Week 7 README"
git push
```

Then, from the project folder, replace the existing VM using OpenTofu:

```powershell
tofu apply "-replace=openstack_compute_instance_v2.week7"
```

Read the plan carefully before typing `yes`. Replacing the VM can interrupt the live webpage while the new instance starts. The floating IP is managed separately in the configuration, but its address should still be verified after replacement.

Wait a minute or two for cloud-init to finish, then open [http://128.214.255.177/](http://128.214.255.177/) and press **Ctrl + F5** to reload the page without using the browser's cached copy.

## 9. Experiments

### Experiment 1 – Change and replacement

- **Change:** Edited the `user_data` (cloud-init configuration) and separately edited only the security group description.
- **Result:** The `user_data` change caused the VM to be replaced because the configuration is used during the initial boot. The security group description change was applied in place.
- **Lesson:** `tofu plan` shows whether a change will update a resource or destroy and recreate it.

### Experiment 2 – Configuration drift

- **Change:** Changed the security group description manually in cPouta to `MANUAL DRIFT TEST`.
- **Result:** `tofu plan` detected that the real infrastructure differed from the configuration and planned to change the description back.
- **Lesson:** Manual dashboard changes can cause configuration drift. Infrastructure as Code makes those differences visible.

### Experiment 3 – Destroy and rebuild

- **Change:** Ran `tofu destroy`, followed by `tofu apply`.
- **Result:** Seven resources were destroyed and seven resources were created again from the same configuration. After cloud-init finished, the webpage worked again. The private IP changed because the VM and network port were recreated.
- **Lesson:** The environment can be rebuilt from code instead of repeating the dashboard setup manually.

Evidence screenshots are available in the `screenshots/` folder and on the live webpage.

## 10. Week 1 compared with Week 7

| Week 1 – Manual setup | Week 7 – OpenTofu |
|---|---|
| Resources created through the cPouta dashboard | Resources described in configuration files |
| Server setup required manual steps | cloud-init automates the initial setup |
| Rebuilding required repeating the steps | OpenTofu recreates the declared infrastructure |
| Configuration was harder to reproduce | Configuration is reviewable and stored in Git |
| Manual changes were easy to overlook | `tofu plan` reveals differences |

## 11. What I learned

Describing the infrastructure as code took more effort at first than creating it through the dashboard. However, the configuration makes the environment repeatable. `tofu plan` shows the changes before they are applied, and configuration drift becomes easier to identify.

I also learned that some changes require resource replacement, cloud-init runs during the initial boot, and security group rules must be configured carefully. Manual setup is useful for quick experiments, while Infrastructure as Code is useful for environments that need to be reviewed, reproduced, or shared.

## 12. Links

- **GitHub repository:** [https://github.com/Mishomoon/cloud-services-week7](https://github.com/Mishomoon/cloud-services-week7)
- **Live webpage:** [http://128.214.255.177/](http://128.214.255.177/)
- **OpenTofu documentation:** [https://opentofu.org/docs/](https://opentofu.org/docs/)
- **CSC cPouta documentation:** [https://docs.csc.fi/cloud/pouta/](https://docs.csc.fi/cloud/pouta/)
