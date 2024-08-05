# AsN_GrApEr

This script helps you fetch Autonomous System Numbers (ASNs) associated with a given domain, extract their subnet information, and save it in a sorted and unique list. The script uses `curl` to fetch data and `grep` to extract the relevant information.

## Basic Working

1. **URL Encoding Function**: Converts special characters in the domain name to URL-safe characters.
2. **Domain Fetch**: Fetches the ASN information page for the given domain from `bgp.he.net`.
3. **ASN Extraction**: Extracts ASNs from the fetched page.
4. **Subnet Information Fetch**: For each ASN, fetches the corresponding page and extracts subnet information.
5. **Sorting and Cleaning**: Sorts and removes duplicate subnet entries.
6. **Output**: Saves the final sorted and unique list of subnets in a file named after the domain.

## Installation

To install and use this script, you need to have `git` and `curl` installed on your system.

### Clone the Repository and Run the script

```bash
git clone https://github.com/Byte-BloggerBase/AsN_GrApEr.git
cd AsN_GrApEr
./ASN_greper.sh "Test org"
```
