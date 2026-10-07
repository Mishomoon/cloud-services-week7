# Cloud Services – Week 7
## Infrastructure as Code with OpenTofu

This repository contains my **Cloud Services Week 7** project, where I rebuilt my cloud environment using **Infrastructure as Code (IaC)** with **OpenTofu**.

Instead of creating and configuring the environment manually, I described the infrastructure in code and used OpenTofu to create, update, test, destroy and rebuild it.

The project was built using **OpenTofu, OpenStack/cPouta, Ubuntu, cloud-init and Apache**.

---

## ☁️ What I Built

The final environment contains:

- Ubuntu Linux virtual machine
- OpenStack network port
- Security group
- SSH access restricted to my own IP
- HTTP access from the Internet
- SSH key pair
- Floating IP
- Apache web server
- Automatically generated webpage using cloud-init

The VM was successfully created in cPouta and the webpage was tested with an **HTTP 200 response**.

---

## 🛠️ How It Works

The main infrastructure is defined in:

| File | Purpose |
|---|---|
| `main.tf` | Creates the main OpenStack resources |
| `variables.tf` | Defines the project input variables and validation |
| `outputs.tf` | Defines information returned by OpenTofu |
| `provider.tf` | Configures the OpenStack provider |
| `cloud-init.yaml` | Installs Apache and configures the webpage |
| `index.html` | Full Week 7 project documentation |
| `.gitignore` | Prevents sensitive files from being committed |
| `screenshots/` | Evidence from the implementation and experiments |

---

## 🚀 OpenTofu Workflow

I used the normal OpenTofu workflow:


tofu init
      ↓
tofu validate
      ↓
tofu plan
      ↓
tofu apply
      ↓
test the infrastructure

After the infrastructure was working, I also tested changes, configuration drift, destruction and rebuilding.
🧪 Experiments
1. Infrastructure Changes
I tested two different types of changes.
Cloud-init change
Changing the cloud-init configuration caused the VM to be replaced.
Security group change
Changing the security group description was handled as an in-place update.
This helped me understand why some infrastructure changes require replacement while others can be changed without recreating the resource.
The actual OpenTofu plans and results are available in the screenshots/ folder.
2. Configuration Drift
For the drift experiment, I changed the security group manually in the cPouta web interface.
I changed the description to:
MANUAL DRIFT TEST

I then ran:
tofu plan

OpenTofu detected that the real infrastructure was different from the configuration and planned to change it back.
This showed how IaC can detect configuration drift.
3. Destroy and Rebuild
I tested whether the infrastructure could be recreated from the code.
First:
tofu destroy

Then:
tofu apply

The environment was successfully rebuilt.
After the rebuild, cloud-init configured Apache again and the webpage became available.
The destroy, rebuild and final webpage evidence can be found in screenshots/.
🌐 Final Webpage
The VM runs Apache and serves my Week 7 webpage.
The final test returned:
HTTP 200

The webpage itself contains my full Week 7 documentation, including the IaC questions, implementation details, experiments, problems and reflection.
The complete documentation is available in:
index.html

🔐 Security
Security was also part of the implementation.
SSH was restricted to my own IP address, while HTTP was opened so the webpage could be accessed publicly.
I also used .gitignore to keep sensitive infrastructure information out of the repository.
Sensitive files such as:
terraform.tfstate
*.tfvars
private SSH keys
OpenStack RC files
passwords
credentials

should not be committed to GitHub.
📸 Evidence
I included the relevant screenshots from the actual implementation in the screenshots/ folder.
They show things such as:
- OpenTofu initialization
- Validation
- Planning
- Applying
- VM information
- Network configuration
- Security configuration
- Apache running
- Working webpage
- HTTP 200 response
- Infrastructure changes
- Configuration drift
- Destroy and rebuild
The screenshots are kept in the repository so the implementation can be checked directly rather than relying only on descriptions in this README.
📚 Documentation
The main project documentation is available in:
index.html
It contains my answers to the Part A questions, the Part B implementation, experiments, screenshots/slideshows, problems and solutions, reflection and conclusion.
The repository also contains the actual OpenTofu configuration used to build the environment, so the documentation can be compared with the code.

🎯 Reflection
The main thing I learned from this project was the difference between manually managing infrastructure and managing it as code.
With OpenTofu, I could describe the environment once and use the configuration to create, change, destroy and rebuild it.
The experiments also showed me that OpenTofu does more than create resources. It can compare the desired configuration with the real infrastructure, detect differences and show what needs to change.
The destroy and rebuild experiment was especially useful because it showed that the environment could be recreated from the configuration instead of manually setting everything up again.
