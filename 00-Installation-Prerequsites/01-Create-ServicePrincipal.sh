SP_CREATION_RESULT=$(az ad sp create-for-rbac --name "$AAD_APP_DISPLAY_NAME" \
                                             --role Owner \
                                             --scopes "/subscriptions/$SUBSCRIPTION_ID" \
                                             --skip-assignment) # Skip role assignment for now

CLIENT_SECRET=$(echo $SP_CREATION_RESULT | jq -r '.password')
echo "Created service principal with secret (keep this safe!): $CLIENT_SECRET"

# Optional: Assign Role to Service Principal
# az role assignment create --assignee $APPLICATION_ID --role Owner --scope "/subscriptions/$SUBSCRIPTION_ID"

