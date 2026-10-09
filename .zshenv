if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH=/apollo/env/ApolloCommandLine/bin:/apollo/env/envImprovement/bin:$PATH
else
    # Laptops have no EC2 metadata service; skip the SDK's slow IMDS probe.
    # Clouddesks need IMDS, so this stays out of the shared Claude settings.
    export AWS_EC2_METADATA_DISABLED=true
fi

. "$HOME/.cargo/env"

# Added by AIM CLI
export PATH="/local/home/luchay/.aim/mcp-servers:$PATH"
