# Docker Image Scans
This GitHub action is used to scan the Docker image passed to it, and can be called from workflows. The only input variable needed is the Docker image that has been created.

## Important Notes
- Please note that some vulnerability scanners scan for the same vulnerability, but in different ways, so a finding in one scanner might not show up in the results of another scanner. This is dependent on things such as the scanner's regex to determine if the vulnerability is there or not

## Scanners

### Anchore

The [anchore/scan-action](https://github.com/anchore/scan-action) scanner is built on top of [Grype](https://github.com/anchore/grype). Anchore can be used to scan directories and SBOM files as well, the instructions on this are on the repo.

#### Supported Distributions, Packages, and Libraries

**Supported Linux Distributions:**
- Alpine
- BusyBox
- CentOS and RedHat
- Debian and Debian-based distros like Ubuntu

**Supported packages and libraries:**
- Ruby Bundles
- Python Wheel, Egg, requirements.txt
- JavaScript NPM/Yarn
- Java JAR/EAR/WAR, Jenkins plugins JPI/HPI
- Go modules

### Trivy

The [aquasecurity/trivy-action](https://github.com/aquasecurity/trivy-action) scanner is another vulnerability scanner. The list of supported image types are not readily available compared to other scanners, but it is confirmed to work with both python and java images.

### Dockle
The [hands-lab/dockle-action](https://github.com/hands-lab/dockle-action) scanner scans the Docker image for any dangerous items, best-practices, and vulnerabilities. It is able to scan any Docker image, but the depth of findings depends on the OS of the image scanned.

## To use this action

To scan an image, use the following code block as a guideline, making sure to fill in the needed information

```
- name: Build and tag Docker image
  id: build-image
  env:
    ECR_REGISTRY: "Your ECR registry goes here"
    ECR_REPOSITORY: "Your ECR repo goes here"
    IMAGE_TAG: "The image tag goes here"
  run: |
    echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

- name: Scan docker image
  uses: ./.github/actions/image-scan
  with:
    image: ${{ steps.build-image.outputs.image }}
```