
# Set Up SonarQube

You can deploy the community version of SonarQube on GCE or GKE. For the quickest and simplest setup for the demo purposes, we recommend you either leverage 



* The GCP Marketplace [SonarQube Packaged by Bitnami](https://console.cloud.google.com/marketplace/product/bitnami-launchpad/sonarqube?project=slsa-demo) or;
* SonarQube [Helm Chart deployment](https://docs.sonarqube.org/latest/setup/sonarqube-on-kubernetes/)

After the installation, log in SonarQube as the administrator.



* Create a new project and name it “`slsa-demo`”

![alt_text](https://github.com/kenpkz/gcp-slsa-demo/blob/master/images/sonarqube.png)




* Choose “Other CI”, generate a token called `slsa-demo` and <span style="text-decoration:underline;">note down the token (we will save the token in GCP Secret Manager later on)</span>



<p id="gdcalert2" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image2.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert3">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image2.png "image_tooltip")




<p id="gdcalert3" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image3.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert4">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image3.png "image_tooltip")



# Set Up Snyk

We will use the community version Snyk for this demo.



* Browse to [https://snyk.io](https://snyk.io) and click “Sign Up” button on the top right hand side
* Use your Github or personal gmail account to sign up the free version
* In Snyk, create a “CLI” new project in your Snyk organisation



<p id="gdcalert4" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image4.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert5">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image4.png "image_tooltip")




* Click the drop-down arrow under your first name initial on the top right hand side and choose Account Settings
* Generate an Auth Token <span style="text-decoration:underline;">note down the token (we will save the token in GCP Secret Manager later on)</span>



<p id="gdcalert5" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image5.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert6">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image5.png "image_tooltip")




* Click the “gear” icon on the top right hand side, click “Integrations” and click “Edit settings” for Container Registries -> GCR



<p id="gdcalert6" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image6.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert7">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image6.png "image_tooltip")




* Follow the instructions on the page to provision the GCP Service Account (ensure you create the Service Account in the same project for the SLSA demo) and paste the JSON key file content in the JSON key file tab



<p id="gdcalert7" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image7.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert8">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image7.png "image_tooltip")



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



<p id="gdcalert8" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image8.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert9">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image8.png "image_tooltip")




* Ensure the KMS Key ring is called `slsa-ga-keyring` and the key is called `slsa-ga-key`



<p id="gdcalert9" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image9.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert10">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image9.png "image_tooltip")




* Configure the Binary Authorisation policy to have default deny, and require attestor for both GKE clusters



<p id="gdcalert10" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image10.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert11">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image10.png "image_tooltip")



# Set Up GCP Cloud Build



* Replace the branch-pattern (for the simplicity, you can use either ^main$ or ^master$) with the repo you created 

<p id="gdcalert11" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: undefined internal link (link text: "here"). Did you generate a TOC? </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert12">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>

[here](#heading=h.vmys2yijn5db) and then run below command

    


```
gcloud beta builds triggers create cloud-source-repositories \
    --name="slsa-ga-demo-build" \
    --repo=slsa-demo-ga \
    --branch-pattern=^main$ \
    --build-config=cloudbuild.yaml 
```




* Create a Pub/Sub topic called `slsa-demo-ga-release` to link the Cloud Build triggers



<p id="gdcalert12" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image11.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert13">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image11.png "image_tooltip")




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



<p id="gdcalert13" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image12.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert14">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image12.png "image_tooltip")




* Upon completion, the second “release” Cloud Build is waiting for manual approval. You can log in SonarQube, Snyk, and GCR Vulnerability Scan to check the findings. And you can Approve or Reject the release. _Note: For more advanced use cases, we can use “if” script in the Cloud Build to query either or both SonarQube and Snyk for findings, and fail the Cloud Build there. This version of demo is opting for a manual approval release gate_



<p id="gdcalert14" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image13.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert15">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image13.png "image_tooltip")




* Upon approving the release Cloud Build, you can see the Cloud Deploy is deploying the signed container to the target clusters, you can use the “promote” button to release to the “production” cluster



<p id="gdcalert15" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image14.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert16">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image14.png "image_tooltip")

