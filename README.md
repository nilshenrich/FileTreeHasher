# FileTreeHasher
Tool for hashing and checking multiple files within a directory structure.\
The tool can be installed as Windows package or run as executable for Windows, Linux or MacOS (under development).

## Table of contents

1. [Installation of Windows package](#installation-of-windows-package)
    1. [Install certificate](#install-certificate)
    1. [Install bundle](#install-bundle)

## Installation of Windows package

As the installable Windows package bundle is not available from Microsoft store, the certificate must be set to trusted before starting.

### Install certificate

After downloading and unpacking the release setup asset, please follow the steps to install the certificate.

1. Open certificate with double click:\
![Open cert](Screenshots\UWP_TrustCert\SC_CertInBundle.png)

1. Now a windows with certificate information should open saying, that this certificate is not trusted. Please click on "Install Certificate...":\
![Install cert](Screenshots\UWP_TrustCert\SC_CertInfoNotTrusted.png)

1. When you are asked where to store the certificate, select the option "Place all certificates in the following store" and click "Browsw..." to select a store:\
![Place cert](Screenshots\UWP_TrustCert\SC_PlaceCertInStore.png)

1. Please select the store "Trusted Root Certification Authorities" and click "OK":\
![Select store](Screenshots\UWP_TrustCert\SC_SelectCertStore.png)\
![Store selected](Screenshots\UWP_TrustCert\SC_PlaceCertInStore-path.png)

1. If thee certificate is installed properly, the success screen is shown:\
![Cert complete](Screenshots\UWP_TrustCert\SC_CertImportComplete.png)\
![Cert success](Screenshots\UWP_TrustCert\SC_CertImportSuccess.png)

Now you can continue with installing the side load package.

### Install bundle

To install the windows package from bundle, please just click on the .msixbundle file.\
If not done, you must allow installation from side load in your Windows settings, the installation process will guide you through.