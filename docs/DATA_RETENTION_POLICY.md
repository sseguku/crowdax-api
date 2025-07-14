# Data Retention Policy

**Effective Date:** July 14, 2025  
**Version:** 1.0  
**Compliance:** Uganda Data Protection and Privacy Act, 2019

## 1. Purpose

This policy establishes the framework for retaining and disposing of personal data in accordance with legal requirements and business needs. It ensures compliance with the Uganda Data Protection and Privacy Act, 2019, and other applicable regulations.

## 2. Legal Framework

### 2.1 Regulatory Requirements

- **Uganda Data Protection and Privacy Act, 2019**
- **Bank of Uganda KYC/AML Regulations**
- **Financial Services Regulations**
- **Tax and Accounting Requirements**

### 2.2 Retention Principles

- Data minimization and purpose limitation
- Secure storage and disposal
- Regular review and cleanup
- Audit trail maintenance

## 3. Data Categories and Retention Periods

### 3.1 User Account Data

| Data Type           | Retention Period              | Legal Basis           | Disposal Method   |
| ------------------- | ----------------------------- | --------------------- | ----------------- |
| User profiles       | 7 years after account closure | Regulatory compliance | Secure deletion   |
| Authentication logs | 5 years                       | Security monitoring   | Automated cleanup |
| Consent records     | 7 years after withdrawal      | Legal requirement     | Secure deletion   |

### 3.2 KYC and Identity Data

| Data Type                     | Retention Period           | Legal Basis           | Disposal Method   |
| ----------------------------- | -------------------------- | --------------------- | ----------------- |
| KYC documents                 | 5 years after verification | AML regulations       | Secure deletion   |
| Identity verification records | 5 years                    | Regulatory compliance | Secure deletion   |
| Verification logs             | 5 years                    | Audit requirements    | Automated cleanup |

### 3.3 Financial Data

| Data Type           | Retention Period | Legal Basis           | Disposal Method |
| ------------------- | ---------------- | --------------------- | --------------- |
| Investment records  | 7 years          | Financial regulations | Secure deletion |
| Transaction logs    | 7 years          | Tax compliance        | Secure deletion |
| Payment information | 7 years          | Financial regulations | Secure deletion |

### 3.4 Campaign and Business Data

| Data Type               | Retention Period         | Legal Basis      | Disposal Method |
| ----------------------- | ------------------------ | ---------------- | --------------- |
| Campaign data           | 7 years after completion | Business records | Secure deletion |
| Investment agreements   | 7 years                  | Legal contracts  | Secure deletion |
| Business communications | 5 years                  | Business records | Secure deletion |

### 3.5 Security and Audit Data

| Data Type      | Retention Period | Legal Basis         | Disposal Method   |
| -------------- | ---------------- | ------------------- | ----------------- |
| Security logs  | 5 years          | Security monitoring | Automated cleanup |
| Breach records | 7 years          | Legal requirement   | Secure deletion   |
| Audit trails   | 5 years          | Compliance          | Automated cleanup |

## 4. Data Disposal Procedures

### 4.1 Secure Deletion

- **Electronic Data:** Overwrite with random data, then delete
- **Database Records:** Use secure deletion procedures
- **Backup Data:** Include in regular backup rotation
- **Log Files:** Automated cleanup with verification

### 4.2 Physical Records

- **Paper Documents:** Cross-cut shredding
- **Storage Media:** Physical destruction
- **Certification:** Destruction certificates maintained

### 4.3 Third-Party Disposal

- **Service Providers:** Contractual disposal requirements
- **Cloud Storage:** Provider deletion procedures
- **Verification:** Confirmation of disposal completion

## 5. Retention Schedule

### 5.1 Active Data

- **Current Users:** Full retention during active period
- **Suspended Accounts:** 30-day grace period
- **Pending Deletions:** 30-day processing period

### 5.2 Inactive Data

- **Closed Accounts:** 7-year retention period
- **Unverified KYC:** 1-year retention
- **Failed Transactions:** 2-year retention

### 5.3 Archive Data

- **Historical Records:** Compressed storage
- **Compliance Data:** Encrypted archive
- **Backup Data:** Regular rotation

## 6. Automated Cleanup

### 6.1 Scheduled Jobs

```ruby
# Daily cleanup
- Failed login attempts (older than 30 days)
- Temporary files (older than 7 days)
- Session data (older than 24 hours)

# Weekly cleanup
- Audit logs (older than 5 years)
- Security logs (older than 5 years)
- Backup rotation

# Monthly cleanup
- User data (closed accounts older than 7 years)
- KYC data (older than 5 years)
- Transaction logs (older than 7 years)
```

### 6.2 Cleanup Verification

- **Automated Checks:** Verify deletion completion
- **Audit Trails:** Log all cleanup activities
- **Error Handling:** Retry failed deletions
- **Reporting:** Monthly cleanup reports

## 7. Regulatory Holds

### 7.1 Legal Holds

- **Litigation:** Data preserved during legal proceedings
- **Investigation:** Data preserved during investigations
- **Regulatory Inquiry:** Data preserved during inquiries

### 7.2 Hold Procedures

- **Identification:** Mark data for preservation
- **Notification:** Inform relevant parties
- **Monitoring:** Regular hold status reviews
- **Release:** Formal release procedures

## 8. Data Anonymization

### 8.1 Anonymization Criteria

- **Research Purposes:** Statistical analysis
- **Testing:** System development
- **Compliance:** Regulatory reporting

### 8.2 Anonymization Methods

- **Personal Identifiers:** Removal or replacement
- **Quasi-identifiers:** Generalization
- **Sensitive Data:** Aggregation
- **Verification:** Re-identification testing

## 9. Monitoring and Compliance

### 9.1 Regular Reviews

- **Monthly:** Retention policy compliance
- **Quarterly:** Data inventory updates
- **Annually:** Policy effectiveness review

### 9.2 Compliance Reporting

- **Regulatory Reports:** Annual compliance reports
- **Internal Audits:** Quarterly internal reviews
- **External Audits:** Annual external assessments

## 10. Exception Handling

### 10.1 Extension Requests

- **Business Need:** Extended retention for business purposes
- **Legal Requirement:** Extended retention for legal compliance
- **Approval Process:** Formal approval required

### 10.2 Emergency Procedures

- **Data Recovery:** Emergency data recovery procedures
- **Legal Requests:** Expedited legal hold procedures
- **Breach Response:** Emergency data preservation

## 11. Training and Awareness

### 11.1 Staff Training

- **Annual Training:** Data retention policy training
- **Role-Specific:** Tailored training for different roles
- **Updates:** Training on policy changes

### 11.2 Awareness Programs

- **Regular Communications:** Policy reminders
- **Best Practices:** Data handling guidelines
- **Incident Response:** Emergency procedures

## 12. Policy Review

### 12.1 Review Schedule

- **Annual Review:** Complete policy review
- **Regulatory Updates:** Review for regulatory changes
- **Technology Updates:** Review for technology changes

### 12.2 Update Procedures

- **Stakeholder Input:** Gather feedback from stakeholders
- **Legal Review:** Legal department review
- **Approval Process:** Formal approval required
- **Communication:** Staff notification of changes

---

**Last Updated:** July 14, 2025  
**Next Review:** January 14, 2026  
**Policy Owner:** Data Protection Officer
