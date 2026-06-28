if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH=/apollo/env/ApolloCommandLine/bin:/apollo/env/envImprovement/bin:$PATH
fi

. "$HOME/.cargo/env"

# Added by AIM CLI
export PATH="/local/home/luchay/.aim/mcp-servers:$PATH"
