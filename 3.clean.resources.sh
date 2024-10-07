SERVICE_URL=$(gcloud run services describe apintsync --format 'value(status.url)' --project $PROJECT_ID --region $REGION)

sed -i "s,$PROJECT_ID,PROJECT_ID,g" ./integrations/dev/authconfigs/IntegrationService.json
sed -i "s,$SERVICE_URL,SERVICE_URL,g" ./integrations/dev/authconfigs/IntegrationService.json
sed -i "s,$SERVICE_URL,SERVICE_URL,g" ./integrations/dev/config-variables/APIM-Sync-config.json
sed -i "s,$USER_EMAIL,USER_EMAIL,g" ./integrations/dev/config-variables/APIM-Sync-config.json