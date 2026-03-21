# AWS Multi-Account Landing Zone using AWS Control Tower

This project demonstrates how to design and deploy a real-world **AWS Multi-Account Landing Zone** using **AWS Organizations and AWS Control Tower**.  
The goal of this setup is to build a secure, scalable, production-ready AWS environment following Enterprise best-practices.

---

## 🔹 Project Overview

Most companies do not run everything inside a single AWS account.  
Instead, they separate environments and workloads into **multiple AWS accounts** for:

• Security isolation  
• Cost transparency  
• Least-privilege access  
• Governance & compliance  
• Reduced blast-radius  

This project walks through:

✔ Setting up AWS Organizations  
✔ Deploying AWS Control Tower  
✔ Creating OUs (Org Units) for environment separation  
✔ Creating and structuring AWS accounts  
✔ Centralized logging & monitoring  
✔ Security services enablement  
✔ Identity-based account access  

---

## 🔹 Account & OU Structure

This Landing Zone follows a **recommended enterprise structure**:

### Security OU
• Log Archive Account  
• Audit Account  

### Shared Services OU
• Networking Account  
• CI/CD Account  
• Monitoring Account  

### Workload OUs
• Development Account  
• Testing / QA Account  
• Production Account  

Each account has a dedicated purpose to keep workloads isolated and governance simple.

---

## 🔹 Security & Monitoring Layer

Core AWS security services enabled:

• AWS CloudTrail (Organization-wide logging)  
• AWS Config  
• AWS GuardDuty  
• AWS Security Hub  
• IAM Identity Center (SSO)  
• Centralized S3 logging  

This ensures full visibility across every AWS account.

---

## 🔹 Why This Project Matters

This Landing Zone design is commonly used by:

• Cloud / DevOps Engineers  
• Cloud Security Teams  
• Platform Engineering  
• FinOps & Cost Governance Teams  

It prepares you for **real-world AWS environments** — not just lab demos.

---

## 🔹 Documentation

The **complete step-by-step project guide with architecture diagrams** is included in this repository:

📄 `AWS-Multi-Account-Landing-Zone-Project.pdf`

This document explains:

• Architecture  
• Setup flow  
• AWS console steps  
• Security concepts  
• Practical notes  

---

## 🔹 Tech Stack

• AWS Control Tower  
• AWS Organizations  
• AWS IAM Identity Center  
• AWS CloudTrail  
• AWS Config  
• AWS GuardDuty  
• AWS Security Hub  
• AWS S3  

---

## 🔹 Author

This project was created as part of a **Cloud / DevOps learning journey** to simulate a real enterprise AWS platform setup.

---

## 🔹 Feedback & Collaboration

If you want to improve, suggest changes, or collaborate — feel free to connect 🙂

