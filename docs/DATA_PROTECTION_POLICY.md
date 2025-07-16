# Data Protection Policy

**Effective Date**: January 2025  
**Version**: 1.0  
**Last Updated**: January 2025

## Table of Contents

- [Introduction](#introduction)
- [Scope and Application](#scope-and-application)
- [Definitions](#definitions)
- [Data Protection Principles](#data-protection-principles)
- [Legal Basis for Processing](#legal-basis-for-processing)
- [Data Subject Rights](#data-subject-rights)
- [Data Security](#data-security)
- [Data Breach Management](#data-breach-management)
- [Data Retention](#data-retention)
- [Third-Party Data Processors](#third-party-data-processors)
- [International Data Transfers](#international-data-transfers)
- [Compliance and Monitoring](#compliance-and-monitoring)
- [Contact Information](#contact-information)

## Introduction

Crowdax API ("we," "our," or "us") is committed to protecting the privacy and personal data of our users in accordance with the Uganda Data Protection and Privacy Act, 2019 (UPDA). This policy outlines how we collect, use, store, and protect personal data in the course of providing our crowdfunding and investment platform services.

### Our Commitment

We are committed to:

- Protecting the privacy and personal data of all users
- Complying with applicable data protection laws and regulations
- Being transparent about our data processing activities
- Implementing appropriate technical and organizational security measures
- Respecting and upholding data subject rights

## Scope and Application

### Who This Policy Applies To

This policy applies to:

- All users of the Crowdax API platform
- Our employees, contractors, and service providers
- Any third parties who process personal data on our behalf
- All data processing activities related to our services

### What Data This Policy Covers

This policy covers:

- Personal data collected through our platform
- Data processed for user authentication and authorization
- KYC (Know Your Customer) and verification data
- Financial and investment data
- Communication and marketing data
- Technical and usage data

## Definitions

**Personal Data**: Any information relating to an identified or identifiable natural person.

**Data Subject**: The individual to whom personal data relates.

**Data Controller**: The entity that determines the purposes and means of processing personal data.

**Data Processor**: The entity that processes personal data on behalf of the controller.

**Processing**: Any operation performed on personal data, including collection, recording, storage, alteration, retrieval, use, disclosure, or destruction.

**Consent**: Any freely given, specific, informed, and unambiguous indication of the data subject's wishes.

**Data Breach**: A security incident leading to accidental or unlawful destruction, loss, alteration, unauthorized disclosure, or access to personal data.

## Data Protection Principles

We adhere to the following data protection principles:

### 1. Lawfulness, Fairness, and Transparency

- We process personal data lawfully, fairly, and transparently
- We provide clear information about data processing activities
- We obtain valid consent where required

### 2. Purpose Limitation

- We collect personal data for specified, explicit, and legitimate purposes
- We do not process personal data for incompatible purposes
- We clearly communicate the purposes of data collection

### 3. Data Minimization

- We collect only the personal data necessary for our purposes
- We regularly review and minimize data collection
- We implement data anonymization where possible

### 4. Accuracy

- We ensure personal data is accurate and up-to-date
- We provide mechanisms for data correction
- We implement data quality controls

### 5. Storage Limitation

- We retain personal data only for as long as necessary
- We have clear data retention policies
- We securely delete data when no longer needed

### 6. Integrity and Confidentiality

- We implement appropriate security measures
- We protect personal data against unauthorized access
- We ensure data integrity and availability

### 7. Accountability

- We demonstrate compliance with data protection principles
- We maintain records of processing activities
- We conduct regular compliance assessments

## Legal Basis for Processing

We process personal data based on the following legal grounds:

### 1. Consent

We process personal data with explicit consent for:

- Marketing communications
- Newsletter subscriptions
- Optional data collection
- Third-party data sharing

**Withdrawal of Consent**: Users may withdraw consent at any time through:

- Access through: `DELETE /api/v1/users/consent`
- Email notification to: privacy@crowdax.com
- Account settings in the platform

### 2. Contract Performance

We process personal data to:

- Provide our crowdfunding platform services
- Process investments and transactions
- Manage user accounts and profiles
- Provide customer support

### 3. Legal Obligations

We process personal data to comply with:

- KYC and AML regulations
- Tax reporting requirements
- Financial services regulations
- Data protection laws

### 4. Legitimate Interests

We process personal data for legitimate interests including:

- Platform security and fraud prevention
- Service improvement and analytics
- Business operations and administration
- Legal proceedings and dispute resolution

## Data Subject Rights

We respect and uphold the following data subject rights:

### 1. Right to Access

Users have the right to access their personal data and receive information about:

- What personal data we hold
- How we use their data
- Who we share their data with
- How long we retain their data

**Implementation**:

- Access through: `GET /api/v1/users/data`
- Response time: Within 30 days
- Format: Structured, machine-readable format

### 2. Right to Rectification

Users have the right to correct inaccurate or incomplete personal data.

**Implementation**:

- Access through: `PUT /api/v1/users/data`
- Response time: Within 30 days
- Validation: Data accuracy verification

### 3. Right to Erasure (Right to be Forgotten)

Users have the right to request deletion of their personal data, subject to legal requirements.

**Implementation**:

- Access through: `DELETE /api/v1/users/data`
- Response time: Within 30 days
- Retention: Legal hold capabilities for regulatory requirements

### 4. Right to Data Portability

Users have the right to receive their personal data in a portable format.

**Implementation**:

- Access through: `GET /api/v1/users/data/export`
- Response time: Within 30 days
- Format: JSON/CSV export

### 5. Right to Object

Users have the right to object to data processing based on legitimate interests.

**Implementation**:

- Access through: `DELETE /api/v1/users/consent`
- Response time: Immediate
- Effect: Stops further processing

### 6. Right to Restrict Processing

Users have the right to restrict processing in certain circumstances.

**Implementation**:

- Contact: privacy@crowdax.com
- Response time: Within 30 days
- Effect: Limited processing while investigation

## Data Security

We implement comprehensive security measures to protect personal data:

### 1. Technical Security Measures

- **Encryption**: AES-256 encryption for data at rest and TLS 1.2+ for data in transit
- **Authentication**: Multi-factor authentication and JWT tokens
- **Access Control**: Role-based access control and least privilege principles
- **Network Security**: Firewalls, VPNs, and secure network architecture
- **Application Security**: Input validation, SQL injection prevention, and XSS protection

### 2. Organizational Security Measures

- **Staff Training**: Regular data protection and security training
- **Access Management**: Regular access reviews and privilege management
- **Incident Response**: Comprehensive incident response procedures
- **Vendor Management**: Security assessments of third-party processors
- **Physical Security**: Secure data centers and office facilities

### 3. Monitoring and Detection

- **Security Monitoring**: 24/7 security monitoring and alerting
- **Audit Logging**: Comprehensive audit trails for all data access
- **Anomaly Detection**: Automated detection of suspicious activities
- **Regular Assessments**: Security audits and penetration testing

## Data Breach Management

### 1. Breach Detection and Response

We have established procedures for:

- **Detection**: Automated monitoring and manual detection
- **Assessment**: Risk assessment and impact analysis
- **Containment**: Immediate containment measures
- **Investigation**: Thorough investigation and evidence preservation
- **Remediation**: Corrective actions and system improvements

### 2. Notification Requirements

In the event of a data breach, we will:

- **Regulatory Notification**: Notify UCC within 72 hours of becoming aware
- **Data Subject Notification**: Notify affected individuals without undue delay
- **Documentation**: Maintain records of all breach incidents
- **Communication**: Provide clear and accurate information about the breach

### 3. Breach Response Team

Our breach response team includes:

- Data Protection Officer
- IT Security Team
- Legal Team
- Communications Team
- External Security Consultants

## Data Retention

### 1. Retention Periods

We retain personal data for the following periods:

- **User Account Data**: 7 years after account closure (regulatory requirement)
- **KYC Documents**: 7 years after account closure (regulatory requirement)
- **Transaction Records**: 7 years (regulatory requirement)
- **Marketing Data**: Until consent withdrawal or 2 years of inactivity
- **System Logs**: 1 year for security monitoring
- **Backup Data**: 30 days for operational recovery

### 2. Data Deletion

When data is no longer needed, we:

- Securely delete data using industry-standard methods
- Verify deletion through audit procedures
- Maintain deletion records for compliance
- Notify third parties of data deletion where required

### 3. Legal Hold

We may retain data beyond normal retention periods when:

- Required by legal proceedings
- Subject to regulatory investigation
- Needed for legitimate business purposes
- Required by applicable laws

## Third-Party Data Processors

### 1. Processor Selection

We carefully select third-party processors based on:

- Security capabilities and certifications
- Compliance with data protection laws
- Reputation and track record
- Technical and organizational measures

### 2. Data Processing Agreements

All third-party processors are bound by:

- Written data processing agreements
- Security and confidentiality obligations
- Compliance with our data protection policies
- Audit and monitoring rights

### 3. Current Processors

Our current data processors include:

- **Cloud Infrastructure**: DigitalOcean (data hosting)
- **Email Services**: SendGrid (transactional emails)
- **Payment Processing**: Stripe (payment processing)
- **Analytics**: Google Analytics (website analytics)
- **Monitoring**: Sentry (error tracking)

## International Data Transfers

### 1. Transfer Safeguards

When transferring data internationally, we ensure:

- Adequate protection through appropriate safeguards
- Compliance with local data protection laws
- Risk assessment of transfer destinations
- Documentation of transfer mechanisms

### 2. Transfer Mechanisms

We use the following transfer mechanisms:

- Standard Contractual Clauses (SCCs)
- Adequacy decisions
- Binding corporate rules
- Other approved transfer mechanisms

## Compliance and Monitoring

### 1. Compliance Framework

We maintain a comprehensive compliance framework including:

- Regular compliance assessments
- Policy reviews and updates
- Staff training and awareness
- Audit and monitoring procedures

### 2. Data Protection Officer

Our Data Protection Officer:

- Monitors compliance with data protection laws
- Provides advice on data protection matters
- Handles data subject requests
- Coordinates with regulatory authorities

### 3. Regular Reviews

We conduct regular reviews of:

- Data processing activities
- Security measures and controls
- Third-party processor relationships
- Compliance with legal requirements

## Contact Information

### Data Protection Officer

For data protection inquiries:

- **Email**: dpo@crowdax.com
- **Phone**: +256 XXX XXX XXX
- **Address**: [Company Address], Kampala, Uganda

### General Inquiries

For general privacy inquiries:

- **Email**: privacy@crowdax.com
- **Support**: support@crowdax.com

### Regulatory Authority

Uganda Communications Commission (UCC):

- **Website**: https://www.ucc.co.ug
- **Email**: info@ucc.co.ug
- **Phone**: +256 41 433 1000

## Policy Updates

This policy is reviewed and updated regularly to ensure compliance with:

- Changes in data protection laws
- New regulatory requirements
- Technology and security developments
- Business process changes

**Last Updated**: January 2025  
**Next Review**: April 2025  
**Version**: 1.0

---

_This policy is part of our commitment to protecting your privacy and personal data. We encourage you to read this policy carefully and contact us if you have any questions._
