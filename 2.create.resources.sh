gcloud config set project $PROJECT_ID

# create service account and assign roles
gcloud iam service-accounts create "api-integration-service" \
    --description="Service account to manage api and integration automation" \
    --display-name="API Integration Service"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:api-integration-service@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

# deploy apintsync to cloud run
SECONDS=0
gcloud run deploy apintsync --image apint/apintsync:latest --region $REGION --no-allow-unauthenticated \
    --set-env-vars APIGEE_PROJECT=$PROJECT_ID,APIGEE_REGION=$REGION,AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID,AZURE_RESOURCE_GROUP=$RESOURCE_GROUP,AZURE_SERVICE_NAME=$SERVICE_NAME,AZURE_CLIENT_ID=$CLIENT_ID,AZURE_CLIENT_SECRET=$CLIENT_SECRET,AZURE_TENANT_ID=$TENANT_ID,AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY,AWS_REGION=$AWS_REGION
duration=$SECONDS
echo "Deployment finished in $((duration / 60)) minutes and $((duration % 60)) seconds."
# get deployed URL
SERVICE_URL=$(gcloud run services describe apintsync --format 'value(status.url)' --project $PROJECT_ID --region $REGION)

# update integration files with variables
sed -i "s,PROJECT_ID,$PROJECT_ID,g" ./integrations/dev/authconfigs/IntegrationService.json
sed -i "s,SERVICE_URL,$SERVICE_URL,g" ./integrations/dev/authconfigs/IntegrationService.json
sed -i "s,SERVICE_URL,$SERVICE_URL,g" ./integrations/dev/config-variables/APIM-Sync-config.json
sed -i "s,USER_EMAIL,$USER_EMAIL,g" ./integrations/dev/config-variables/APIM-Sync-config.json

# deploy integration flow
integrationcli integrations apply -f integrations -e dev --wait=true -p $PROJECT_ID -t $(gcloud auth print-access-token) -r $REGION --sa api-integration-service --sp $PROJECT_ID
