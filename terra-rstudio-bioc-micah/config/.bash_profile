# Copy user config files from workspace
gsutil -m cp -r ${WORKSPACE_BUCKET}/analyst/micah/home/* ~/

# Copy the shared Renv cache from the workspace
gsutil -m cp -r ${WORKSPACE_BUCKET}/tools/renv ~/

# Set my git username and email
git config --global user.name "micahpf"
git config --global user.email "micahpfletcher@gmail.com"
