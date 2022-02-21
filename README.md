
# Set Up SonarQube

You can deploy the community version of SonarQube on GCE or GKE. For the quickest and simplest setup for the demo purposes, we recommend you either leverage 



* The GCP Marketplace [SonarQube Packaged by Bitnami](https://console.cloud.google.com/marketplace/product/bitnami-launchpad/sonarqube?project=slsa-demo) or;
* SonarQube [Helm Chart deployment](https://docs.sonarqube.org/latest/setup/sonarqube-on-kubernetes/)

After the installation, log in SonarQube as the administrator.



* Create a new project and name it “`slsa-demo`”

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/sonarqube.png)


* Choose “Other CI”, generate a token called `slsa-demo` and <span style="text-decoration:underline;">note down the token (we will save the token in GCP Secret Manager later on)</span>


![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/sonarproject.png)




# Set Up Snyk

We will use the community version Snyk for this demo.



* Browse to [https://snyk.io](https://snyk.io) and click “Sign Up” button on the top right hand side
* Use your Github or personal gmail account to sign up the free version
* In Snyk, create a “CLI” new project in your Snyk organisation

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/snyk.png)




* Click the drop-down arrow under your first name initial on the top right hand side and choose Account Settings
* Generate an Auth Token <span style="text-decoration:underline;">note down the token (we will save the token in GCP Secret Manager later on)</span>


![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/snyk-token.png)




* Click the “gear” icon on the top right hand side, click “Integrations” and click “Edit settings” for Container Registries -> GCR


![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/snyk-gcr.png)



* Follow the instructions on the page to provision the GCP Service Account (ensure you create the Service Account in the same project for the SLSA demo) and paste the JSON key file content in the JSON key file tab


![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/snyk-gcr2.png)




# Set Up Demo GKE Clusters



* Create slsa-no-asm and slsa clusters

```
gcloud container clusters create slsa-no-asm \
    --zone asia-east1 \
    --node-locations asia-east1-a

gcloud container clusters create slsa\
    --zone asia-east1 \
    --node-locations asia-east1-a
```




# Set Up GCP Secret Manager



* SLSA_SNYK_TOKEN with value from [Snyk Auth Token above](#bookmark=id.p0c0phiknoth)

```
printf "YOUR TOKEN" | gcloud secrets create SLSA_SNYK_TOKEN --data-file=-
```


* SLSA_SONAR_TOKEN with value from [SonarQube token above](#bookmark=id.kodyke6fbq9)

```
printf "YOUR TOKEN" | gcloud secrets create SLSA_SONAR_TOKEN --data-file=-
```




# Set Up Code Repository



* In the CloudShell or your local IDE, clone the demo code from [here](https://github.com/kenpkz/gcp-continuous-compliance-demo);
* Create a Source Repository called `slsa-demo-ga` and push the downloaded code to your own Source Repository using [this guide](https://cloud.google.com/source-repositories/docs/pushing-code-from-a-repository#cloud-sdk); 


# Set Up GCP Binary Authorisation Attestor



* Follow the doc [here](https://cloud.google.com/binary-authorization/docs/creating-attestors-console) to set up an Attestor called `slsa-attestor   `

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/attestor.png)





* Ensure the KMS Key ring is called `slsa-ga-keyring` and the key is called `slsa-ga-key`


![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/keys.png)





* Configure the Binary Authorisation policy to have default deny, and require attestor for both GKE clusters

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/policy.png)




# Set Up GCP Cloud Build



* Replace the branch-pattern (for the simplicity, you can use either ^main$ or ^master$) with the repo you created above and then run below command


```
gcloud beta builds triggers create cloud-source-repositories \
    --name="slsa-ga-demo-build" \
    --repo=slsa-demo-ga \
    --branch-pattern=^main$ \
    --build-config=cloudbuild.yaml 
```




* Create a Pub/Sub topic called `slsa-demo-ga-release` to link the Cloud Build triggers

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/pubsub.png)





* Create the release Cloud Build Trigger

```
gcloud alpha builds triggers create pubsub \
  --name="slsa-demo-ga-release" \
  --repo=slsa-demo-ga \
  --topic=projects/slsa-demo/topics/slsa-demo-ga-release \
  --build-config=cloudbuild-release.yaml \
  --branch=^main$ \
  --require-approval
```




# Set Up GCP Cloud Deploy



* Run the command at the git repository root to create the Cloud Deploy pipeline, replace the project and region

```
gcloud deploy apply --file=cloud-deploy/clouddeploy.yaml --region=asia-east1 --project=YOUR_PROJECT
```




# Test The Demo



* In the git repo, push changes to the Source Repository, e.g., git add . && git commit -m 'run demo && git push google
* You should see the Cloud Build is being triggered, the “build & scan” Cloud Build usually goes for ~6.5 minutes


![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/cb1.png)




* Upon completion, the second “release” Cloud Build is waiting for manual approval. You can log in SonarQube, Snyk, and GCR Vulnerability Scan to check the findings. And you can Approve or Reject the release. _Note: For more advanced use cases, we can use “if” script in the Cloud Build to query either or both SonarQube and Snyk for findings, and fail the Cloud Build there. This version of demo is opting for a manual approval release gate_

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/cb2.png)




* Upon approving the release Cloud Build, you can see the Cloud Deploy is deploying the signed container to the target clusters, you can use the “promote” button to release to the “production” cluster

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/deploy.png)

