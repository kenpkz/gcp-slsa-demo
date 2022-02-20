#!/bin/zsh
# Replace with your GPC project ID
DEPLOYER_PROJECT_ID=slsa-demo
DEPLOYER_PROJECT_NUMBER="$(
    gcloud projects describe "${DEPLOYER_PROJECT_ID}" \
      --format="value(projectNumber)"
)"

# Replace with your GPC project ID
ATTESTOR_PROJECT_ID=slsa-demo
ATTESTOR_PROJECT_NUMBER="$(
    gcloud projects describe "${ATTESTOR_PROJECT_ID}" \
    --format="value(projectNumber)"
)"
DEPLOYER_SERVICE_ACCOUNT="service-${DEPLOYER_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"
ATTESTOR_SERVICE_ACCOUNT="service-${ATTESTOR_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

function createNote {
  NOTE_ID=$1
  DESCRIPTION=$2
  NOTE_URI="projects/${ATTESTOR_PROJECT_ID}/notes/${NOTE_ID}"

cat > /tmp/note_payload.json << EOM
{
  "name": "${NOTE_URI}",
  "attestation": {
    "hint": {
      "human_readable_name": "${DESCRIPTION}"
    }
  }
}
EOM
  curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)"  \
    -H "x-goog-user-project: ${ATTESTOR_PROJECT_ID}" \
    --data-binary @/tmp/note_payload.json  \
    "https://containeranalysis.googleapis.com/v1/projects/${ATTESTOR_PROJECT_ID}/notes/?noteId=${NOTE_ID}"  
}

NOTE_ID="slsa-pass"
#CreateNote $NOTE_ID "pass static code analysis"

# Replace with your KMS Key information here
KMS_KEY_PROJECT_ID=${ATTESTOR_PROJECT_ID}
KMS_KEYRING_NAME=slsa-ga-keyring
KMS_KEY_NAME=slsa-ga-key
KMS_KEY_LOCATION=global
KMS_KEY_PURPOSE=asymmetric-signing
KMS_KEY_ALGORITHM=ec-sign-p256-sha256
KMS_PROTECTION_LEVEL=software
KMS_KEY_VERSION=1

# Create Keyring
gcloud kms keyrings create ${KMS_KEYRING_NAME} \
  --location ${KMS_KEY_LOCATION}

# Create the Signing Key
gcloud kms keys create ${KMS_KEY_NAME} \
  --location ${KMS_KEY_LOCATION} \
  --keyring ${KMS_KEYRING_NAME}  \
  --purpose ${KMS_KEY_PURPOSE} \
  --default-algorithm ${KMS_KEY_ALGORITHM} \
  --protection-level ${KMS_PROTECTION_LEVEL}


# Create Attestor
ATTESTOR_NAME=slsa-attestor
gcloud --project="${ATTESTOR_PROJECT_ID}" \
     container binauthz attestors create "${ATTESTOR_NAME}" \
    --attestation-authority-note="${NOTE_ID}" \
    --attestation-authority-note-project="${ATTESTOR_PROJECT_ID}"

gcloud container binauthz attestors add-iam-policy-binding \
  "projects/${ATTESTOR_PROJECT_ID}/attestors/${ATTESTOR_NAME}" \
  --member="serviceAccount:${DEPLOYER_SERVICE_ACCOUNT}" \
  --role=roles/binaryauthorization.attestorsVerifier

gcloud --project="${ATTESTOR_PROJECT_ID}" \
     container binauthz attestors public-keys add \
    --attestor="${ATTESTOR_NAME}" \
    --keyversion-project="${ATTESTOR_PROJECT_ID}" \
    --keyversion-location="${KMS_KEY_LOCATION}" \
    --keyversion-keyring="${KMS_KEYRING_NAME}" \
    --keyversion-key="${KMS_KEY_NAME}" \
    --keyversion="${KMS_KEY_VERSION}"
