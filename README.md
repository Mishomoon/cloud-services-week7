# Cloud Services – Week 7

## Infrastructure as Code with OpenTofu

This repository contains my Cloud Services Week 7 project, where I rebuilt my cloud environment using Infrastructure as Code (IaC) with OpenTofu.

Instead of creating and configuring the environment manually, I described the infrastructure in code and used OpenTofu to create, update, test, destroy and rebuild it.

The project uses:

- OpenTofu
- OpenStack / cPouta
- Ubuntu
- cloud-init
- Apache

---

## ☁️ What I Built

The final environment contains:

- Ubuntu Linux virtual machine
- OpenStack network port
- Security group
- SSH access restricted to my allowed IP address
- HTTP access from the Internet
- SSH key pair
- Floating IP
- Apache web server
- Week 7 webpage deployed with cloud-init

The VM was successfully created in cPouta and the webpage was tested with an HTTP 200 response.

---

## 📁 Project Files

| File | Purpose |
|---|---|
| `main.tf` | Defines the OpenStack resources used by the project |
| `variables.tf` | Defines project input variables and validation |
| `outputs.tf` | Defines information returned by OpenTofu |
| `provider.tf` | Configures the OpenStack provider |
| `cloud-init.yaml` | Installs Apache and deploys the webpage and project files |
| `index.html` | Full Week 7 project documentation webpage |
| `.gitignore` | Prevents sensitive files from being committed |
| `screenshots/` | Contains evidence from the implementation and experiments |
| `Cloud service (6).pdf` | Project documentation used by the deployed webpage |

---

## 🔧 How the Deployment Works

OpenTofu defines the infrastructure as code.

The main workflow I used was:

```text
tofu init
      ↓
tofu validate
      ↓
tofu plan
      ↓
tofu apply
      ↓
test the infrastructure

I also tested infrastructure changes, configuration drift, destruction and rebuilding.
☁️ Cloud-init
The VM uses cloud-init during its first boot.
The cloud-init configuration:
1. Installs Apache.
2. Installs Git.
3. Removes the default Apache index.html.
4. Clones my public GitHub repository.
5. Copies index.html to the Apache web directory.
6. Copies the screenshots to the Apache web directory.
7. Copies the Week 1 PDF to the Apache web directory.
8. Starts Apache.
Because cloud-init clones the GitHub repository during the VM's first boot, the repository must remain public and contain the files required by cloud-init.
🧪 Experiments
1. Infrastructure Changes
I tested two different types of configuration changes.
Cloud-init / user_data change
Changing the VM user_data caused the VM to be replaced.
This happened because user_data contains first-boot configuration. A new VM is needed for the changed cloud-init configuration to be applied during first boot.
Security group description change
Changing only the security group description was handled as an in-place update.
This showed that not every infrastructure change requires a resource to be destroyed and recreated.
2. Configuration Drift
For the drift experiment, I manually changed the security group description through the cPouta web interface.
I changed the description to:
MANUAL DRIFT TEST

I then ran:
tofu plan

OpenTofu detected that the real infrastructure was different from the configuration and planned to change the description back.
This demonstrated how Infrastructure as Code can detect configuration drift.
The experiment also showed that tofu plan compares the declared configuration with the known state and provider information. Manual changes that are not represented in the configuration can therefore be detected when they affect managed resources.
3. Destroy and Rebuild
I tested whether the infrastructure could be recreated from the OpenTofu configuration.
First I ran:
tofu destroy

The destroy operation removed the seven OpenTofu-managed resources.
The floating IP allocation itself was not destroyed because it was looked up as an existing resource. The OpenTofu configuration managed its association with the VM.
After the destroy, I rebuilt the environment with:
tofu apply

The apply created the seven managed resources again.
The VM was successfully rebuilt and cloud-init configured Apache again. The webpage became available after the VM finished its first-boot configuration.
🌐 Final Webpage
The VM runs Apache and serves my Week 7 documentation webpage.
The final webpage returned:
HTTP 200

The webpage contains my Week 7 documentation, including:
- Part A questions
- Infrastructure implementation
- OpenTofu resources and dependencies
- Experiments
- Security
- Problems and solutions
- Reflection
- Conclusion
The complete documentation is available in:
index.html

🔐 Security
Security was also part of the implementation.
SSH access was restricted to the allowed IP address, while HTTP access was opened to the Internet so that the webpage could be accessed publicly.
I also used .gitignore to prevent sensitive files from being committed to GitHub.
The .gitignore includes patterns for files such as:
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
cloud.yaml
clouds.yaml
*.pem
*.key
id_rsa
id_rsa.*
.env

Sensitive infrastructure files, credentials and private keys should not be committed to the repository.
📸 Evidence
The screenshots/ folder contains evidence from the actual implementation and experiments.
The screenshots include evidence of:
- OpenTofu initialization
- OpenTofu validation
- OpenTofu planning
- OpenTofu apply
- OpenTofu outputs
- VM information
- Floating IP
- SSH key pair
- HTTP access
- Apache running
- Working webpage
- HTTP 200 response
- Infrastructure changes
- Configuration drift
- Destroy and rebuild
The screenshots are included so that the implementation can be checked directly rather than relying only on descriptions.
📚 Documentation
The main project documentation is available in:
index.html

It contains my answers to the Part A questions and the Part B implementation, including:
- OpenTofu configuration
- Resources and dependencies
- Experiments
- Screenshots and slideshows
- Security
- Problems and solutions
- Reflection
- Final result
- Conclusion
The repository also contains the actual OpenTofu configuration used to build the environment, so the documentation can be compared with the code.
🎯 Reflection
The main thing I learned from this project was the difference between manually managing infrastructure and managing infrastructure as code.
With OpenTofu, I could describe the environment in code and use the same configuration to create, change, destroy and rebuild the infrastructure.
The experiments showed me that OpenTofu does more than create resources. It can compare the desired configuration with the real infrastructure, detect differences and show what needs to change.
The destroy and rebuild experiment was especially useful because I could remove the managed resources and create the environment again from the configuration.
During the rebuild, the private IP address changed from the previous VM address to a new private IP, while the public floating IP remained the same. The seven OpenTofu-managed resources were recreated.
This helped me understand that Infrastructure as Code makes the infrastructure reproducible and easier to manage than configuring everything manually.
✅ Final Result
The Week 7 infrastructure was successfully created and rebuilt using OpenTofu.
The final environment included the VM, network port, security group, security rules, SSH key pair and floating IP association.
Apache successfully served the Week 7 webpage, and the final webpage test returned HTTP 200.
The project demonstrates Infrastructure as Code using OpenTofu with OpenStack/cPouta.

### Why I changed it

I specifically fixed the problems in your old README:

- ✅ Proper `##` headings
- ✅ Proper code blocks
- ✅ Proper project-file table
- ✅ Experiments separated clearly
- ✅ Security section separated
- ✅ Evidence section separated
- ✅ Reflection separated
- ✅ Added the **real cloud-init → public GitHub → Apache** dependency
- ✅ Removed the missing `versions.tf` because your actual `git ls-files` does **not** show it
- ✅ Didn't invent exact timings
- ✅ Didn't invent extra experiment results
- ✅ Kept your real `MANUAL DRIFT TEST`
- ✅ Kept the real HTTP 200 result
- ✅ Kept the real destroy/rebuild result
- ✅ Mentioned the real private/public IP behavior without putting unnecessary IP details in the README

**Do not commit yet.** First replace the README with this version.
