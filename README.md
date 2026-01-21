# ☁️ Lab 0 — Infrastructure Bootstrap (Terraform)

In this lab, **I built a reproducible, disposable EC2 lab environment using Terraform**, designed to act as a **stable baseline** for all my future Linux, Docker, and DevOps labs.

My focus was **idempotency, safety, and determinism** — being able to create and destroy infrastructure confidently without manual cleanup.

---

## 📋 Lab Overview

### 🎯 Goal

My goal in this lab was to:

* Provision a single EC2 instance using Terraform
* Restrict SSH access to **my IP only**
* Use an **existing EC2 key pair**
* Ensure the setup is **reproducible and tear-down safe**
* Establish a baseline environment for future labs

### 🎓 Learning Outcomes

By completing this lab, I learned how to:

* Structure a clean Terraform project (`main.tf`, `variables.tf`, `outputs.tf`)
* Use Terraform **data sources** to discover existing AWS resources
* Make infrastructure deterministic using a **provider block**
* Debug real-world Terraform issues (region mismatch, key pair lookup failures)
* Validate infrastructure by successfully SSHing into the instance
* Safely clean up resources using `terraform destroy`

---

## 🛠 Step-by-Step Journey

### Step 1: Define the Goal (Infrastructure Bootstrap)

My objective was to create a **clean EC2 lab box** that:

* I can provision repeatedly with the same result (idempotent)
* I can safely destroy after each lab
* Acts as a foundation for all future experiments

I intentionally avoided over-engineering at this stage (no modules yet).

---

### Step 2: Create Terraform File Structure

```bash
mkdir lab-0-infra
cd lab-0-infra
touch main.tf variables.tf outputs.tf terraform.tfvars provider.tf
```

This structure clearly separates:

* **What I’m building**
* **What I can change**
* **What Terraform returns**
* **How Terraform talks to AWS**

---

### Step 3: Make Terraform Deterministic with a Provider

A major turning point in this lab was realizing that **Terraform is not deterministic without an explicit provider block**.

**provider.tf**

```hcl
provider "aws" {
  region = var.region
}
```

Before this, Terraform could:

* Look in the wrong region
* Fail to find existing resources
* Behave differently from the AWS CLI and console

Adding the provider made Terraform predictable.

---

### Step 4: Discover Existing AWS Resources (Data Sources)

Instead of hardcoding values, I used Terraform **data sources** to dynamically discover:

* The default VPC
* Default subnets
* An existing EC2 key pair
* The latest Amazon Linux 2023 AMI

This allowed the configuration to adapt automatically to the environment.

---

### Step 5: Create a Security Group (SSH Only from My IP)

I designed the security group so that:

* Inbound SSH is allowed **only** from my public IP (`/32`)
* All outbound traffic is allowed

This reinforces **least-privilege networking**, even for lab infrastructure.

---

### Step 6: Provision the EC2 Instance

I provisioned the EC2 instance with:

* Instance type: `t3.small`
* AMI: Amazon Linux 2023
* Subnet: First default subnet discovered
* SSH key: Existing EC2 key pair
* Security group: SSH-restricted SG

All resources were tagged to make cleanup easy.

---

### Step 7: Initialize, Plan, and Apply

```bash
terraform init
terraform plan
terraform apply
```

Once the provider was defined, Terraform behaved consistently and predictably.

---

### Step 8: SSH into the Instance

```bash
chmod 400 labec2.pem
ssh -i labec2.pem ec2-user@<public_dns>
```

Successfully SSHing confirmed that:

* The key pair was resolved correctly
* The security group rules were correct
* The instance was reachable

---

### Step 9: Destroy the Infrastructure

```bash
terraform destroy
```

This confirmed that the environment is **fully disposable** and safe to recreate at any time.

---

## 🧠 1. What Was Actually Wrong Before (The Real Lesson)

The error I encountered was:

```
Error: no matching EC2 Key Pair found
```

### What I initially thought

> “Terraform can’t see my key pair, but the AWS console shows it exists.”

### What was actually happening

Terraform was asking AWS:

> “Do you have a key pair named `labec2` in the region/account I’m currently using?”

And AWS answered:

> “No.”

Meanwhile, my AWS CLI command worked because I explicitly specified the region:

```bash
aws ec2 describe-key-pairs --region eu-west-2
```

Terraform, however, was guessing.

---

## ⚠️ The Critical Concept I Learned

### Terraform **without a provider block is non-deterministic**

If I don’t define:

```hcl
provider "aws" {
  region = ...
}
```

Terraform will:

* Guess the region
* Guess the profile
* Guess the account
* Use whatever credentials it finds first

This leads to situations where:

* CLI ≠ Terraform
* Console ≠ Terraform
* Data sources appear to fail for “no reason”

This is why my key pair lookup failed.

---

## ✅ 2. Why Creating `provider.tf` Fixed Everything

When I added:

```hcl
provider "aws" {
  region = var.region
}
```

I explicitly told Terraform:

> “Always talk to AWS in this region.”

### Alignment after the fix

| Tool        | Region    |
| ----------- | --------- |
| AWS Console | eu-west-2 |
| AWS CLI     | eu-west-2 |
| Terraform   | eu-west-2 |

Now, when Terraform asked AWS:

> “Do you have a key pair named `labec2`?”

AWS replied:

> “Yes.”

That’s why the error disappeared without changing anything else.

---

## 🧠 Why This Was a Huge Learning Win

I didn’t just fix an error — I learned:

* Why data sources fail even when resources exist
* Why Terraform must be deterministic
* Why provider configuration is foundational
* Why many infrastructure bugs come from **context**, not syntax

---

## 🔑 Mental Model I’ll Remember Forever

> **Terraform is blind without a provider.
> If I don’t tell it where to look, it will look somewhere else.**

---

## ✅ Final Checklist — Lab 0 Status

I can now confidently say:

* Terraform knows which AWS region to use
* Terraform sees existing AWS resources
* `terraform plan` runs without prompting for subnet/VPC
* EC2 key pair lookup works
* SSH access is validated
* The lab is reproducible and safe to destroy

**Lab 0 is complete and solid.**

